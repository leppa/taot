/*
 *  TAO Translator
 *  Copyright (C) 2013-2016  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
 *
 *  $Id: $Format:%h %ai %an$ $
 *
 *  This file is part of TAO Translator.
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
#ifdef Q_OS_BLACKBERRY
#   include <bb/cascades/Application>
#   include <bb/cascades/ThemeSupport>
#   include <bb/cascades/Theme>
#   include <bb/cascades/ColorTheme>
#   include <bb/system/InvokeManager>
#   include "bb10/dictionarymodel.h"
#else
#   include "dictionarymodel.h"
#endif
#include "services/googletranslate.h"
#include "services/microsofttranslator.h"
#include "services/yandextranslate.h"
#include "services/yandexdictionaries.h"

#ifdef WITH_ANALYTICS
#   include "services/apikeys.h"
# ifdef Q_OS_SAILFISH
#   include "ssu_interface.h"
# endif
#   include <QAmplitudeAnalytics>
#endif

#include <qplatformdefs.h>

#ifdef Q_OS_SAILFISH
#   include <QTextDocument>
#   include <QStandardPaths>
#   include <QDir>
#endif

#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
#   include <QDeclarativeEngine>
#else
#   include <QQmlEngine>
#endif

SourceTranslatedTextPair::SourceTranslatedTextPair(QObject *parent)
    : QObject(parent)
{}

SourceTranslatedTextPair::SourceTranslatedTextPair(const StringPair &translit, QObject *parent)
    : QObject(parent)
    , m_sourceText(translit.first)
    , m_translatedText(translit.second)
{}

QString SourceTranslatedTextPair::sourceText() const
{
    return m_sourceText;
}

QString SourceTranslatedTextPair::translatedText() const
{
    return m_translatedText;
}

TranslationInterface::TranslationInterface(QObject *parent)
    : QObject(parent)
    , m_service(NULL)
    , m_serviceItem(NULL)
    , m_busy(false)
    , m_suppressRetranslate(false)
    , m_sourceLanguages(new LanguageListModel(this))
    , m_targetLanguages(new LanguageListModel(this))
    , m_sourceLanguage(NULL)
    , m_targetLanguage(NULL)
    , m_dict(new DictionaryModel(this))
#ifdef Q_OS_SAILFISH
    , m_settings(new QSettings("harbour-taot", "taot", this))
#else
    , m_settings(new QSettings(QCoreApplication::organizationName(), "taot", this))
# ifdef WITH_ANALYTICS
    , m_analytics(new QAmplitudeAnalytics(AMPLITUDE_API_KEY))
# endif
#endif
{
#ifdef WITH_ANALYTICS
# if defined(Q_OS_SAILFISH)
    QString path = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);
    path.append(QDir::separator()).append("harbour-taot");
    QDir dir(path);
    if (!dir.exists())
        dir.mkpath(".");
    m_analytics.reset(new QAmplitudeAnalytics(AMPLITUDE_API_KEY,
                                              dir.filePath("QtInAppAnalytics.ini")));

    // HACK: Get proper manufacturer and model values
    // TODO: Remove when QtSystemInfo is allowed in Harbour
    QAmplitudeAnalytics::DeviceInfo di = m_analytics->deviceInfo();
    org::nemo::ssu ssu("org.nemo.ssu", "/org/nemo/ssu", QDBusConnection::systemBus());
    di.manufacturer = ssu.displayName(0 /*Ssu::DeviceManufacturer*/);
    di.model = ssu.displayName(1 /*Ssu::DeviceModel*/);
    m_analytics->setDeviceInfo(di);
# endif

    updatePersistentProperties();
    m_lastKeepAlive = m_settings->value("Analytics/LastKeepAlive", QDate(1970, 1, 1)).toDate();

    m_privacyLevel = PrivacyLevel(m_settings->value("PrivacyLevel", UndefinedPrivacy).toInt());
    if (m_privacyLevel != NoPrivacy)
        m_analytics->setPrivacyEnabled(true);

    bool resetKeepAlive = false;
    if (m_settings->contains("AppInfo/CurrentVersion")) {
        const QString version = m_settings->value("AppInfo/CurrentVersion").toString();
        if (version != QCoreApplication::applicationVersion()) {
            QVariantMap props;
            props.insert("Old Version", version);
            props.insert("New Version", QCoreApplication::applicationVersion());
            m_analytics->trackEvent("Upgrade", props);
            resetKeepAlive = true;

            m_settings->setValue("AppInfo/CurrentVersion", QCoreApplication::applicationVersion());
        }
    } else {
        QVariantMap props;
        props.insert("Version", QCoreApplication::applicationVersion());
        m_analytics->trackEvent("Installation", props);
        resetKeepAlive = true;

        m_settings->setValue("AppInfo/CurrentVersion", QCoreApplication::applicationVersion());
    }

    if (resetKeepAlive) {
        const QDate today(QDate::currentDate());
        m_settings->setValue("Analytics/LastKeepAlive", today);
        m_lastKeepAlive = today;
    }

    if (m_privacyLevel == NoPrivacy) {
        trackSessionStart();
    }
#endif

    setTranscription(new SourceTranslatedTextPair());
    setTranslit(new SourceTranslatedTextPair());

    QStringList list;
    list.insert(GoogleTranslateService, GoogleTranslate::displayName());
    list.insert(MicrosoftTranslatorService, MicrosoftTranslator::displayName());
    list.insert(YandexTranslateService, YandexTranslate::displayName());
    list.insert(YandexDictionariesService, YandexDictionaries::displayName());
    m_services = new TranslationServicesModel(list, this);

    createService(m_settings->value("SelectedService", 0).toUInt());

    connect(this, SIGNAL(sourceLanguageChanged()), SLOT(retranslate()));
    connect(this, SIGNAL(targetLanguageChanged()), SLOT(retranslate()));
    connect(this, SIGNAL(sourceLanguageChanged()), SIGNAL(canSwapLanguagesChanged()));
    connect(this, SIGNAL(targetLanguageChanged()), SIGNAL(canSwapLanguagesChanged()));
    connect(this, SIGNAL(detectedLanguageChanged()), SIGNAL(canSwapLanguagesChanged()));
    connect(this, SIGNAL(error(QString)), SLOT(onError(QString)));

#ifdef Q_OS_SYMBIAN
    connect(qApp, SIGNAL(visibilityChanged()), this, SIGNAL(appVisibilityChanged()));
#endif

#ifdef Q_OS_BLACKBERRY
    m_invoker = new bb::system::InvokeManager();
    connect(m_invoker, SIGNAL(invoked(bb::system::InvokeRequest)),
            this, SLOT(onInvoked(bb::system::InvokeRequest)));
#endif
}

QString TranslationInterface::version()
{
    return QCoreApplication::applicationVersion();
}

TranslationServicesModel *TranslationInterface::supportedServices() const
{
    return m_services;
}

TranslationServiceItem *TranslationInterface::selectedService() const
{
    return m_serviceItem;
}

bool TranslationInterface::supportsTranslation() const
{
    return m_service->supportsTranslation();
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
    if (m_service->isAutoLanguage(m_sourceLanguage->language())
            && m_detectedLanguage.info.isValid())
        return m_service->canSwapLanguages(m_detectedLanguage, m_targetLanguage->language());

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

SourceTranslatedTextPair *TranslationInterface::transcription() const
{
    return m_transcription.data();
}

SourceTranslatedTextPair *TranslationInterface::translit() const
{
    return m_translit.data();
}

DictionaryModel *TranslationInterface::dictionary() const
{
    return m_dict;
}

#ifdef WITH_ANALYTICS
TranslationInterface::PrivacyLevel TranslationInterface::privacyLevel() const
{
    return m_privacyLevel;
}

void TranslationInterface::setPrivacyLevel(PrivacyLevel level)
{
    if (m_privacyLevel == level)
        return;

    if (m_privacyLevel == UndefinedPrivacy) {
        switch (level) {
        case NoPrivacy:
            m_analytics->setPrivacyEnabled(false);
            trackSessionStart();
            break;
        case ErrorsOnlyPrivacy:
        case MaximumPrivacy:
            m_analytics->clearQueuedEvents();
            break;
        default:
            ; // do nothing
        }
    }
    m_privacyLevel = level;
    m_settings->setValue("PrivacyLevel", m_privacyLevel);
    if (m_privacyLevel == NoPrivacy) {
        m_analytics->setPrivacyEnabled(false);
        m_analytics->identifyUser();
    } else {
        m_analytics->setPrivacyEnabled(true);
    }
    emit privacyLevelChanged();
}
#endif

#ifdef Q_OS_SYMBIAN
TranslationInterface::AppVisibility TranslationInterface::appVisibility() const
{
    return AppVisibility(qobject_cast<SymbianApplication *>(qApp)->visibility());
}
#endif

TranslationInterface::~TranslationInterface()
{
#ifdef WITH_ANALYTICS
    if (m_privacyLevel == NoPrivacy) {
        m_analytics->trackEvent("Session End", QVariantMap(), true);
    }
#endif

    delete m_service;
    delete m_services;
    delete m_sourceLanguages;
    delete m_targetLanguages;
    delete m_sourceLanguage;
    delete m_targetLanguage;
    delete m_dict;
    delete m_settings;
}

QVariant TranslationInterface::getSettingsValue(const QString &key,
                                                const QVariant &defaultValue) const
{
    return m_settings->value(key, defaultValue);
}

void TranslationInterface::setSettingsValue(const QString &key, const QVariant &value)
{
    m_settings->setValue(key, value);
#ifdef WITH_ANALYTICS
    updatePersistentProperties();
#endif
}

void TranslationInterface::selectService(int index)
{
    if (index == m_serviceItem->index() || index < 0 || index >= m_services->count())
        return;

    m_settings->setValue("SelectedService", index);
    createService(index);
}

void TranslationInterface::selectSourceLanguage(int index)
{
    const Language lang = m_sourceLanguages->get(index);
    if (m_sourceLanguage && m_sourceLanguage->language() == lang)
        return;

    resetTranslation();
    delete m_sourceLanguage;
    m_sourceLanguage = new LanguageItem(lang, index);
    m_settings->beginGroup(m_service->uid() + "/SourceLanguage");
    m_settings->setValue("Info", m_service->serializeLanguageInfo(lang.info));
    m_settings->endGroup();
    emit sourceLanguageChanged();

    if (m_service->targetLanguagesDependOnSourceLanguage()) {
        m_targetLanguages->setLanguageList(m_service->targetLanguages(lang));
        if (!m_service->targetLanguages(lang).contains(m_targetLanguage->language())) {
            const int i = m_service->targetLanguages(lang).indexOf(m_service->defaultLanguagePair()
                                                                   .second);
            selectTargetLanguage(i < 0 ? 0 : i);
        } else {
            m_targetLanguage->setIndex(m_targetLanguages->indexOf(m_targetLanguage->language()));
            emit targetLanguageChanged();
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
    m_targetLanguage = new LanguageItem(lang, index);
    m_settings->beginGroup(m_service->uid() + "/TargetLanguage");
    m_settings->setValue("Info", m_service->serializeLanguageInfo(lang.info));
    m_settings->endGroup();
    emit targetLanguageChanged();
}

void TranslationInterface::swapLanguages()
{
    const Language oldsrc = m_service->isAutoLanguage(m_sourceLanguage->language())
                            ? m_detectedLanguage
                            : m_sourceLanguage->language();
    resetTranslation();

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
        emit info(tr("Please, enter the source text"));
        return;
    }

    resetTranslation();

#ifdef WITH_ANALYTICS
    if (m_privacyLevel == NoPrivacy) {
        QVariantMap props;
        fillTranslationProperties(props);
        m_analytics->trackEvent("Translation", props);
    } else {
        trackKeepAlive();
    }
#endif

    if (!m_service->translate(m_sourceLanguage->language(),
                              m_targetLanguage->language(),
                              m_srcText)) {
        emit error(m_service->errorString());
        return;
    }

    setBusy(true);
}

void TranslationInterface::trackCheckForUpdates()
{
#ifdef WITH_ANALYTICS
    if (m_privacyLevel == NoPrivacy) {
        m_analytics->trackEvent("Check for Updates", QVariantMap(), true);
    }
#endif
}

#ifdef Q_OS_SAILFISH
// HACK: Sailfish doesn't seem to understand HTML encoded URLs.
QString TranslationInterface::urlDecode(const QString &url) const
{
    QTextDocument doc;
    doc.setHtml(url);
    return doc.toPlainText();
}
#endif

#ifdef Q_OS_BLACKBERRY
void TranslationInterface::invoke(const QString &target,
                                  const QString &action,
                                  const QString &uri) const
{
    bb::system::InvokeRequest request;
    request.setTarget(target);
    request.setAction(action);
    request.setUri(uri);
    m_invoker->invoke(request);
}
#endif

void TranslationInterface::createService(uint id)
{
    m_suppressRetranslate = true;

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
        m_settings->setValue("SelectedService", GoogleTranslateService);
    }
    connect(m_service, SIGNAL(translationFinished(bool)), SLOT(onTranslationFinished(bool)));
    emit selectedServiceChanged();

    const LanguagePair defaults = m_service->defaultLanguagePair();

    m_sourceLanguages->setLanguageList(m_service->sourceLanguages());
    m_settings->beginGroup(m_service->uid() + "/SourceLanguage");
    if (m_settings->contains("Info")) {
        const QVariant info = m_service->deserializeLanguageInfo(m_settings->value("Info").toString());
        Language lang(info, m_service->getLanguageName(info));
        if (m_service->sourceLanguages().contains(lang))
            m_sourceLanguage = new LanguageItem(lang, m_sourceLanguages->indexOf(lang));
    }
    m_settings->endGroup();
    if (!m_sourceLanguage)
        m_sourceLanguage = new LanguageItem(defaults.first,
                                            m_sourceLanguages->indexOf(defaults.first));

    m_targetLanguages->setLanguageList(m_service->targetLanguages(m_sourceLanguage->language()));
    m_settings->beginGroup(m_service->uid() + "/TargetLanguage");
    if (m_settings->contains("Info")) {
        const QVariant info = m_service->deserializeLanguageInfo(m_settings->value("Info").toString());
        Language lang(info, m_service->getLanguageName(info));
        if (m_service->targetLanguages(m_sourceLanguage->language()).contains(lang))
            m_targetLanguage = new LanguageItem(lang, m_targetLanguages->indexOf(lang));
    }
    m_settings->endGroup();
    if (!m_targetLanguage)
        m_targetLanguage = new LanguageItem(defaults.second,
                                            m_targetLanguages->indexOf(defaults.second));

    emit sourceLanguageChanged();
    emit targetLanguageChanged();

    m_suppressRetranslate = false;
    retranslate();
}

void TranslationInterface::resetTranslation()
{
    m_service->cancelTranslation();
    m_service->clear();
    setTranslatedText(QString());
    setTranscription(new SourceTranslatedTextPair());
    setTranslit(new SourceTranslatedTextPair());
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

void TranslationInterface::setTranscription(SourceTranslatedTextPair *transcription)
{
    if (m_transcription.data() == transcription)
        return;

#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    QDeclarativeEngine::setObjectOwnership(transcription, QDeclarativeEngine::CppOwnership);
#else
    QQmlEngine::setObjectOwnership(transcription, QQmlEngine::CppOwnership);
#endif
    m_transcription.reset(transcription);
    emit transcriptionChanged();
}

void TranslationInterface::setTranslit(SourceTranslatedTextPair *translit)
{
    if (m_translit.data() == translit)
        return;

#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    QDeclarativeEngine::setObjectOwnership(translit, QDeclarativeEngine::CppOwnership);
#else
    QQmlEngine::setObjectOwnership(translit, QQmlEngine::CppOwnership);
#endif
    m_translit.reset(translit);
    emit translitChanged();
}

#ifdef WITH_ANALYTICS
void TranslationInterface::fillTranslationProperties(QVariantMap &properties) const
{
    properties.insert("Service", m_service->uid());
    if (m_service->isAutoLanguage(m_sourceLanguage->language()))
        properties.insert("From", "<auto>");
    else
        properties.insert("From", m_sourceLanguage->language().info);
    properties.insert("To", m_targetLanguage->language().info);
    properties.insert("Length", m_srcText.length());
}

void TranslationInterface::updatePersistentProperties()
{
    QVariantMap props;
    QLocale lc;
    const QString lang = getSettingsValue("UILanguage").toString();
    if (!lang.isEmpty())
        lc = QLocale(lang);
    if (lc.language() == QLocale::C)
        lc = QLocale(QLocale::English, QLocale::UnitedStates);
    props.insert("OS Name", m_analytics->deviceInfo().os.name);
    props.insert("UI Language", lc.name());

    // On BlackBerry 10, the default theme (dark/light) depends on the phone model.
    // On other systems, the default theme is the same for all models.
    const bool invertedTheme
#ifdef Q_OS_BLACKBERRY
            = bb::cascades::Application::instance()->themeSupport()->theme()->colorTheme()->style()
              == bb::cascades::VisualStyle::Dark;
#else
            = false;
#endif

    props.insert("Inverted Theme", getSettingsValue("InvertedTheme", invertedTheme).toBool());
    props.insert("Translate on Enter", getSettingsValue("TranslateOnEnter", false).toBool());
    props.insert("Paste'n'Translate", getSettingsValue("TranslateOnPaste", true).toBool());
    m_analytics->setPersistentUserProperties(props);
}

void TranslationInterface::trackSessionStart()
{
    m_analytics->trackEvent("Session Start", QVariantMap(), true);
}

void TranslationInterface::trackKeepAlive()
{
    const QDate today(QDate::currentDate());
    if (m_lastKeepAlive.daysTo(today) != 0) {
        // Send keep-alive once a day so that Amplitude Analytics treats us as an active user
        if (m_privacyLevel != NoPrivacy)
            m_analytics->trackEvent("Keep Alive");

        m_settings->setValue("Analytics/LastKeepAlive", today);
        m_lastKeepAlive = today;
    }
}
#endif

void TranslationInterface::onTranslationFinished(bool success)
{
    setBusy(false);

    if (!m_service->errorString().isEmpty()) {
        if (success) {
            qDebug() << m_service->errorString();
            emit info(m_service->errorString());
        } else {
            qWarning() << m_service->errorString();
            emit error(m_service->errorString());
        }
    }

    setTranslatedText(m_service->translation());
    setTranscription(new SourceTranslatedTextPair(m_service->transcription()));
    setTranslit(new SourceTranslatedTextPair(m_service->translit()));
    setDetectedLanguage(m_service->detectedLanguage());
}

void TranslationInterface::onError(const QString &errorString)
{
#ifdef WITH_ANALYTICS
    if (m_privacyLevel == NoPrivacy || m_privacyLevel == ErrorsOnlyPrivacy) {
        QVariantMap props;
        fillTranslationProperties(props);
        props.insert("Error Message", errorString);
        m_analytics->trackEvent("Error", props);
    }
#else
    Q_UNUSED(errorString);
#endif
}

void TranslationInterface::retranslate()
{
    if (m_suppressRetranslate || m_srcText.isEmpty())
        return;

    translate();
}

#ifdef Q_OS_BLACKBERRY
void TranslationInterface::onInvoked(const bb::system::InvokeRequest &request)
{
    if (request.mimeType() != "text/plain")
        return;

    setSourceText(QString::fromUtf8(request.data()));

#ifdef WITH_ANALYTICS
    if (m_privacyLevel == NoPrivacy) {
        QVariantMap props;
        fillTranslationProperties(props);
        m_analytics->trackEvent("Invoked", props, true);
    }
#endif

    retranslate();
}
#endif
