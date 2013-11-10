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
#include "languagelistmodel.h"
#include "dictionarymodel.h"
#include "services/googletranslate.h"

#include <QDebug>

TranslationInterface::TranslationInterface(QObject *parent)
    : QObject(parent)
    , m_service(NULL)
    , m_busy(false)
    , m_sourceLanguages(new LanguageListModel(this))
    , m_targetLanguages(new LanguageListModel(this))
    , m_sourceLanguage(NULL)
    , m_targetLanguage(NULL)
    , m_dict(new DictionaryModel(this))
    , networkReply(NULL)
{
    createService(settings.value("Service").toUInt());

    connect(&nam, SIGNAL(finished(QNetworkReply*)), SLOT(onRequestFinished(QNetworkReply*)));
    connect(this, SIGNAL(sourceLanguageChanged()), SLOT(translate()));
    connect(this, SIGNAL(targetLanguageChanged()), SLOT(translate()));
}

QString TranslationInterface::version()
{
    return qApp->applicationVersion();
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

void TranslationInterface::translate()
{
    if (m_srcText.isEmpty()) {
        emit error(tr("Please, enter the source text"));
        return;
    }

    resetTranslation();
    setBusy(true);

    networkReply = nam.get(m_service->getTranslationRequest(m_sourceLanguage->language(),
                                                            m_targetLanguage->language(),
                                                            m_srcText));
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

    if (m_service->targetLanguagesDependOnSourceLanguage())
        m_targetLanguages->setLanguageList(m_service->targetLanguages(lang));
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

void TranslationInterface::setSourceText(const QString &sourceText)
{
    if (m_srcText == sourceText)
        return;
    resetTranslation();
    m_srcText = sourceText;
    emit sourceTextChanged();
}

void TranslationInterface::onRequestFinished(QNetworkReply *reply)
{
    Q_ASSERT(reply == networkReply);
    networkReply = NULL;
    setBusy(false);

    if (reply->error() == QNetworkReply::OperationCanceledError) {
        // Operation was canceled by us, ignore this error.
        reply->deleteLater();
        return;
    } else if (reply->error() != QNetworkReply::NoError) {
        qWarning() << reply->errorString();
        emit error(reply->errorString());
        reply->deleteLater();
        return;
    }

    if (!m_service->parseReply(reply->readAll())) {
        emit error(m_service->errorString());
        reply->deleteLater();
        return;
    }
    reply->deleteLater();

    setTranslatedText(m_service->translation());
    setDetectedLanguage(m_service->detectedLanguage());
}

void TranslationInterface::createService(uint id)
{
    delete m_sourceLanguage;
    m_sourceLanguage = NULL;
    delete m_targetLanguage;
    m_targetLanguage = NULL;
    delete m_service;

    switch (id) {
    default:
        m_service = new GoogleTranslate(m_dict, this);
    }

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
    setTranslatedText(QString());
    setDetectedLanguage(Language());
    m_dict->clear();
    if (!networkReply)
        return;
    if (networkReply->isRunning())
        networkReply->abort();
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

TranslationInterface::~TranslationInterface()
{
    delete m_service;
    delete m_sourceLanguages;
    delete m_targetLanguages;
    delete m_sourceLanguage;
    delete m_targetLanguage;
    delete m_dict;
}
