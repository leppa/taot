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

#ifndef TRANSLATIONINTERFACE_H
#define TRANSLATIONINTERFACE_H

#include "translationservice.h"

#include <QObject>
#include <QStringList>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QSettings>

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

    // Translation related properties
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(LanguageListModel *sourceLanguages READ sourceLanguages CONSTANT)
    Q_PROPERTY(LanguageListModel *targetLanguages READ targetLanguages CONSTANT)
    Q_PROPERTY(LanguageItem *sourceLanguage READ sourceLanguage NOTIFY sourceLanguageChanged)
    Q_PROPERTY(LanguageItem *targetLanguage READ targetLanguage NOTIFY targetLanguageChanged)
    Q_PROPERTY(QString sourceText READ sourceText WRITE setSourceText NOTIFY sourceTextChanged)
    Q_PROPERTY(QString detectedLanguageName READ detectedLanguageName NOTIFY detectedLanguageChanged)
    Q_PROPERTY(QString translatedText READ translatedText NOTIFY translatedTextChanged)
    Q_PROPERTY(DictionaryModel *dictionary READ dictionary CONSTANT)

public:
    enum SupportedServices {
        GoogleTranslateService,
    };

    explicit TranslationInterface(QObject *parent = 0);

    static QString version();
    TranslationServicesModel *supportedServices() const;
    TranslationServiceItem *selectedService() const;

    bool busy() const;
    LanguageListModel *sourceLanguages() const;
    LanguageListModel *targetLanguages() const;
    LanguageItem *sourceLanguage() const;
    LanguageItem *targetLanguage() const;
    QString sourceText() const;
    QString detectedLanguageName() const;
    QString translatedText() const;
    DictionaryModel *dictionary() const;

    ~TranslationInterface();

signals:
    void error(const QString &errorString) const;
    void selectedServiceChanged();
    void busyChanged();
    void sourceLanguageChanged();
    void targetLanguageChanged();
    void sourceTextChanged();
    void detectedLanguageChanged();
    void translatedTextChanged();

public slots:
    void selectService(int index);
    void selectSourceLanguage(int index);
    void selectTargetLanguage(int index);
    void setSourceText(const QString &sourceText);
    void translate();

private slots:
    void onRequestFinished(QNetworkReply *reply);

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
    DictionaryModel *m_dict;

    QNetworkAccessManager nam;
    QNetworkReply *networkReply;

    QSettings settings;

    void createService(uint id);
    void resetTranslation();
    void setBusy(bool busy);
    void setDetectedLanguage(const Language &detectedLanguageName);
    void setTranslatedText(const QString &translatedText);
};

#endif // TRANSLATIONINTERFACE_H
