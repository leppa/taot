/*
 *  The Advanced Online Translator
 *  Copyright (C) 2013  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
 *
 *  $Id: $Format:%h %ai %an$ $
 *
 *  This file is part of The Advanced Online Translator.
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "translationinterface.h"

#include "translationservice.h"
#include "translationservicesmodel.h"
#include "languagelistmodel.h"
#include "dictionarymodel.h"
#include "services/googletranslate.h"
#include "services/microsofttranslator.h"
#include "services/yandextranslate.h"
#include "services/yandexdictionaries.h"

#include <qplatformdefs.h>
#include <QDebug>

TranslationInterface::TranslationInterface(QObject *parent)
    : QObject(parent)
    , m_service(NULL)
    , m_serviceItem(NULL)
    , m_busy(false)
    , m_sourceLanguages(new LanguageListModel(this))
    , m_targetLanguages(new LanguageListModel(this))
    , m_sourceLanguage(NULL)
    , m_targetLanguage(NULL)
    , m_dict(new DictionaryModel(this))
{
    QStringList list;
    list.insert(GoogleTranslateService, GoogleTranslate::displayName());
    list.insert(MicrosoftTranslatorService, MicrosoftTranslator::displayName());
    list.insert(YandexTranslateService, YandexTranslate::displayName());
    list.insert(YandexDictionariesService, YandexDictionaries::displayName());
    m_services = new TranslationServicesModel(list, this);

    createService(settings.value("SelectedService", 0).toUInt());

    connect(this, SIGNAL(sourceLanguageChanged()), SLOT(retranslate()));
    connect(this, SIGNAL(targetLanguageChanged()), SLOT(retranslate()));
    connect(this, SIGNAL(sourceLanguageChanged()), SIGNAL(canSwapLanguagesChanged()));
    connect(this, SIGNAL(targetLanguageChanged()), SIGNAL(canSwapLanguagesChanged()));

    // TODO: Remove this after 01.01.2014.
#if defined(Q_OS_SYMBIAN) || defined(MEEGO_EDITION_HARMATTAN)
    if (!settings.contains("displayNokiaStoreNotice"))
        settings.setValue("displayNokiaStoreNotice", true);
#endif
}

QString TranslationInterface::version()
{
    return qApp->applicationVersion();
}

TranslationServicesModel *TranslationInterface::supportedServices() const
{
    return m_services;
}

TranslationServiceItem *TranslationInterface::selectedService() const
{
    return m_serviceItem;
}

bool TranslationInterface::busy() const
{
    return m_busy;
}

LanguageListModel *TranslationInterface::sourceLanguages() const
{
    return m_sourceLanguages;
}

LanguageListModel *TranslationInterface::targetLanguages() const
{
    return m_targetLanguages;
}

LanguageItem *TranslationInterface::sourceLanguage() const
{
    return m_sourceLanguage;
}

LanguageItem *TranslationInterface::targetLanguage() const
{
    return m_targetLanguage;
}

bool TranslationInterface::canSwapLanguages() const
{
    return m_service->canSwapLanguages(m_sourceLanguage->language(), m_targetLanguage->language());
}

QString TranslationInterface::sourceText() const
{
    return m_srcText;
}

QString TranslationInterface::detectedLanguageName() const
{
    return m_detectedLanguage.info.isValid() ? m_detectedLanguage.displayName : "";
}

QString TranslationInterface::translatedText() const
{
    return m_translation;
}

DictionaryModel *TranslationInterface::dictionary() const
{
    return m_dict;
}

TranslationInterface::~TranslationInterface()
{
    delete m_service;
    delete m_services;
    delete m_sourceLanguages;
    delete m_targetLanguages;
    delete m_sourceLanguage;
    delete m_targetLanguage;
    delete m_dict;
}

// HACK: We return a QString here, else JavaScript treats `false` as undefined value.
QString TranslationInterface::getSettingsValue(const QString &key) const
{
    return settings.value(key).toString();
}

void TranslationInterface::setSettingsValue(const QString &key, const QVariant &value)
{
    settings.setValue(key, value);
}

void TranslationInterface::selectService(int index)
{
    if (index == m_serviceItem->index() || index < 0 || index >= m_services->count())
        return;

    settings.setValue("SelectedService", index);
    createService(index);
}

void TranslationInterface::selectSourceLanguage(int index)
{
    const Language lang = m_sourceLanguages->get(index);
    if (m_sourceLanguage && m_sourceLanguage->language() == lang)
        return;

    resetTranslation();
    delete m_sourceLanguage;
    m_sourceLanguage = new LanguageItem(lang);
    settings.beginGroup(m_service->uid() + "/SourceLanguage");
    settings.setValue("Info", m_service->serializeLanguageInfo(lang.info));
    settings.endGroup();
    emit sourceLanguageChanged();

    if (m_service->targetLanguagesDependOnSourceLanguage()) {
        m_targetLanguages->setLanguageList(m_service->targetLanguages(lang));
        if (!m_service->targetLanguages(lang).contains(m_targetLanguage->language())) {
            const int i = m_service->targetLanguages(lang).indexOf(m_service->defaultLanguagePair()
                                                                   .second);
            selectTargetLanguage(i < 0 ? 0 : i);
        }
    }
}

void TranslationInterface::selectTargetLanguage(int index)
{
    const Language lang = m_targetLanguages->get(index);
    if (m_targetLanguage && m_targetLanguage->language() == lang)
        return;

    resetTranslation();
    delete m_targetLanguage;
    m_targetLanguage = new LanguageItem(lang);
    settings.beginGroup(m_service->uid() + "/TargetLanguage");
    settings.setValue("Info", m_service->serializeLanguageInfo(lang.info));
    settings.endGroup();
    emit targetLanguageChanged();
}

void TranslationInterface::swapLanguages()
{
    resetTranslation();
    const Language oldsrc = m_sourceLanguage->language();
    selectSourceLanguage(m_sourceLanguages->indexOf(m_targetLanguage->language()));
    selectTargetLanguage(m_targetLanguages->indexOf(oldsrc));
}

void TranslationInterface::setSourceText(const QString &sourceText)
{
    if (m_srcText == sourceText)
        return;
    resetTranslation();
    m_srcText = sourceText;
    emit sourceTextChanged();
}

void TranslationInterface::translate()
{
    if (m_srcText.isEmpty()) {
        emit error(tr("Please, enter the source text"));
        return;
    }

    resetTranslation();

    if (!m_service->translate(m_sourceLanguage->language(),
                              m_targetLanguage->language(),
                              m_srcText)) {
        emit error(m_service->errorString());
        return;
    }

    setBusy(true);
}

void TranslationInterface::createService(uint id)
{
    delete m_sourceLanguage;
    m_sourceLanguage = NULL;
    delete m_targetLanguage;
    m_targetLanguage = NULL;
    delete m_service;
    delete m_serviceItem;

    switch (id) {
    case MicrosoftTranslatorService:
        m_service = new MicrosoftTranslator(this);
        m_serviceItem = new TranslationServiceItem(MicrosoftTranslatorService,
                                                   MicrosoftTranslator::displayName(), this);
        break;
    case YandexTranslateService:
        m_service = new YandexTranslate(this);
        m_serviceItem = new TranslationServiceItem(YandexTranslateService,
                                                   YandexTranslate::displayName(), this);
        break;
    case YandexDictionariesService:
        m_service = new YandexDictionaries(m_dict, this);
        m_serviceItem = new TranslationServiceItem(YandexDictionariesService,
                                                   YandexDictionaries::displayName(), this);
        break;
    case GoogleTranslateService:
    default:
        m_service = new GoogleTranslate(m_dict, this);
        m_serviceItem = new TranslationServiceItem(GoogleTranslateService,
                                                   GoogleTranslate::displayName(), this);
        settings.setValue("SelectedService", GoogleTranslateService);
    }
    connect(m_service, SIGNAL(translationFinished()), SLOT(onTranslationFinished()));
    emit selectedServiceChanged();

    const LanguagePair defaults = m_service->defaultLanguagePair();

    m_sourceLanguages->setLanguageList(m_service->sourceLanguages());
    settings.beginGroup(m_service->uid() + "/SourceLanguage");
    if (settings.contains("Info")) {
        const QVariant info = m_service->deserializeLanguageInfo(settings.value("Info").toString());
        Language lang(info, m_service->getLanguageName(info));
        if (m_service->sourceLanguages().contains(lang))
            m_sourceLanguage = new LanguageItem(lang);
    }
    settings.endGroup();
    if (!m_sourceLanguage)
        m_sourceLanguage = new LanguageItem(defaults.first);

    m_targetLanguages->setLanguageList(m_service->targetLanguages(m_sourceLanguage->language()));
    settings.beginGroup(m_service->uid() + "/TargetLanguage");
    if (settings.contains("Info")) {
        const QVariant info = m_service->deserializeLanguageInfo(settings.value("Info").toString());
        Language lang(info, m_service->getLanguageName(info));
        if (m_service->targetLanguages(m_sourceLanguage->language()).contains(lang))
            m_targetLanguage = new LanguageItem(lang);
    }
    settings.endGroup();
    if (!m_targetLanguage)
        m_targetLanguage = new LanguageItem(defaults.second);

    emit sourceLanguageChanged();
    emit targetLanguageChanged();
}

void TranslationInterface::resetTranslation()
{
    m_service->cancelTranslation();
    m_service->clear();
    setTranslatedText(QString());
    setDetectedLanguage(Language());
    m_dict->clear();
}

void TranslationInterface::setBusy(bool busy)
{
    if (m_busy == busy)
        return;
    m_busy = busy;
    emit busyChanged();
}

void TranslationInterface::setDetectedLanguage(const Language &detectedLanguage)
{
    if (m_detectedLanguage == detectedLanguage)
        return;
    m_detectedLanguage = detectedLanguage;
    emit detectedLanguageChanged();
}

void TranslationInterface::setTranslatedText(const QString &translatedText)
{
    if (m_translation == translatedText)
        return;
    m_translation = translatedText;
    emit translatedTextChanged();
}

void TranslationInterface::onTranslationFinished()
{
    setBusy(false);

    if (!m_service->errorString().isEmpty()) {
        emit error(m_service->errorString());
        return;
    }

    setTranslatedText(m_service->translation());
    setDetectedLanguage(m_service->detectedLanguage());
}

void TranslationInterface::retranslate()
{
    if (m_srcText.isEmpty())
        return;

    translate();
}
