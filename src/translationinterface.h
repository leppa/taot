/*
 *  TAO Translator
 *  Copyright (C) 2013-2015  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
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

#ifndef TRANSLATIONINTERFACE_H
#define TRANSLATIONINTERFACE_H

#include "translationservice.h"

#ifdef Q_OS_SYMBIAN
#   include "symbian/symbianapplication.h"
#endif

#include <QObject>
#include <QStringList>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QSettings>

#ifdef Q_OS_BLACKBERRY
#   include <bb/system/InvokeRequest>
#endif

class SourceTranslatedTextPair: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString sourceText READ sourceText CONSTANT)
    Q_PROPERTY(QString translatedText READ translatedText CONSTANT)

public:
    SourceTranslatedTextPair(QObject *parent = 0);
    SourceTranslatedTextPair(const StringPair &translit, QObject *parent = 0);
    QString sourceText() const;
    QString translatedText() const;

private:
    QString m_sourceText;
    QString m_translatedText;
};
Q_DECLARE_METATYPE(SourceTranslatedTextPair *)

namespace bb { namespace system { class InvokeManager; } }
class TranslationServicesModel;
class TranslationServiceItem;
class LanguageListModel;
class LanguageItem;
class DictionaryModel;
class TranslationInterface: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString version READ version CONSTANT)
    Q_PROPERTY(TranslationServicesModel *services READ supportedServices CONSTANT)
    Q_PROPERTY(TranslationServiceItem *selectedService READ selectedService NOTIFY selectedServiceChanged)
    Q_PROPERTY(bool supportsTranslation READ supportsTranslation NOTIFY selectedServiceChanged)

    // Translation related properties
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(LanguageListModel *sourceLanguages READ sourceLanguages CONSTANT)
    Q_PROPERTY(LanguageListModel *targetLanguages READ targetLanguages CONSTANT)
    Q_PROPERTY(LanguageItem *sourceLanguage READ sourceLanguage NOTIFY sourceLanguageChanged)
    Q_PROPERTY(LanguageItem *targetLanguage READ targetLanguage NOTIFY targetLanguageChanged)
    Q_PROPERTY(bool canSwapLanguages READ canSwapLanguages NOTIFY canSwapLanguagesChanged)
    Q_PROPERTY(QString sourceText READ sourceText WRITE setSourceText NOTIFY sourceTextChanged)
    Q_PROPERTY(QString detectedLanguageName READ detectedLanguageName NOTIFY detectedLanguageChanged)
    Q_PROPERTY(QString translatedText READ translatedText NOTIFY translatedTextChanged)
    Q_PROPERTY(SourceTranslatedTextPair *transcription READ transcription
                                                       NOTIFY transcriptionChanged)
    Q_PROPERTY(SourceTranslatedTextPair *translit READ translit NOTIFY translitChanged)
    Q_PROPERTY(DictionaryModel *dictionary READ dictionary CONSTANT)

#ifdef Q_OS_SYMBIAN
    Q_PROPERTY(TranslationInterface::AppVisibility appVisibility READ appVisibility
                                                                 NOTIFY appVisibilityChanged)
    Q_ENUMS(AppVisibility)
#endif

public:
    enum SupportedServices {
        GoogleTranslateService,
        MicrosoftTranslatorService,
        YandexTranslateService,
        YandexDictionariesService
    };

#ifdef Q_OS_SYMBIAN
    enum AppVisibility {
        AppNotVisible = SymbianApplication::NotVisible,
        AppPartiallyVisible = SymbianApplication::PartiallyVisible,
        AppFullyVisible = SymbianApplication::FullyVisible
    };
#endif

    explicit TranslationInterface(QObject *parent = 0);

    static QString version();
    TranslationServicesModel *supportedServices() const;
    TranslationServiceItem *selectedService() const;
    bool supportsTranslation() const;

    bool busy() const;
    LanguageListModel *sourceLanguages() const;
    LanguageListModel *targetLanguages() const;
    LanguageItem *sourceLanguage() const;
    LanguageItem *targetLanguage() const;
    bool canSwapLanguages() const;
    QString sourceText() const;
    QString detectedLanguageName() const;
    QString translatedText() const;
    SourceTranslatedTextPair *transcription() const;
    SourceTranslatedTextPair *translit() const;
    DictionaryModel *dictionary() const;

#ifdef Q_OS_SYMBIAN
    TranslationInterface::AppVisibility appVisibility() const;
#endif

    ~TranslationInterface();

signals:
    void error(const QString &errorString) const;
    void selectedServiceChanged();
    void busyChanged();
    void sourceLanguageChanged();
    void targetLanguageChanged();
    void canSwapLanguagesChanged();
    void sourceTextChanged();
    void detectedLanguageChanged();
    void translatedTextChanged();
    void transcriptionChanged();
    void translitChanged();
#ifdef Q_OS_SYMBIAN
    void appVisibilityChanged();
#endif

public slots:
    QVariant getSettingsValue(const QString &key,
                              const QVariant &defaultValue = QVariant()) const;
    void setSettingsValue(const QString &key, const QVariant &value);

    void selectService(int index);
    void selectSourceLanguage(int index);
    void selectTargetLanguage(int index);
    void swapLanguages();
    void setSourceText(const QString &sourceText);
    void translate();

#ifdef Q_OS_SAILFISH
    QString urlDecode(const QString &url) const;
#endif

#ifdef Q_OS_BLACKBERRY
    void invoke(const QString &target, const QString &action, const QString &uri) const;
#endif

private:
    TranslationService *m_service;
    TranslationServicesModel *m_services;
    TranslationServiceItem *m_serviceItem;

    bool m_busy;
    LanguageListModel *m_sourceLanguages;
    LanguageListModel *m_targetLanguages;
    LanguageItem *m_sourceLanguage;
    LanguageItem *m_targetLanguage;
    Language m_detectedLanguage;
    QString m_srcText;
    QString m_translation;
    QScopedPointer<SourceTranslatedTextPair> m_transcription;
    QScopedPointer<SourceTranslatedTextPair> m_translit;
    DictionaryModel *m_dict;

    QSettings *m_settings;

    void createService(uint id);
    void resetTranslation();
    void setBusy(bool busy);
    void setDetectedLanguage(const Language &detectedLanguageName);
    void setTranslatedText(const QString &translatedText);
    void setTranscription(SourceTranslatedTextPair *transcription);
    void setTranslit(SourceTranslatedTextPair *translit);

#ifdef Q_OS_BLACKBERRY
    bb::system::InvokeManager *m_invoker;
#endif

private slots:
    void onTranslationFinished();
    void retranslate();

#ifdef Q_OS_BLACKBERRY
    void onInvoked(const bb::system::InvokeRequest &request);
#endif
};

#endif // TRANSLATIONINTERFACE_H
