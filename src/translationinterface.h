/*
 *  The Advanced Online Translator.
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

#include "dictionarymodel.h"

#include <QObject>
#include <QStringList>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QSettings>

class QScriptValue;

class TranslationInterface: public QObject
{
    Q_OBJECT

    // Translation related properties
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(QString sourceLanguage READ sourceLanguage WRITE setSourceLanguage NOTIFY fromLanguageChanged)
    Q_PROPERTY(QString targetLanguage READ targetLanguage WRITE setTargetLanguage NOTIFY toLanguageChanged)
    Q_PROPERTY(QString sourceText READ sourceText WRITE setSourceText NOTIFY sourceTextChanged)
    Q_PROPERTY(QString detectedLanguage READ detectedLanguage NOTIFY detectedLanguageChanged)
    Q_PROPERTY(QString translatedText READ translatedText NOTIFY translatedTextChanged)
    Q_PROPERTY(DictionaryModel *dictionary READ dictionary NOTIFY dictionaryChanged)

public:
    explicit TranslationInterface(QObject *parent = 0);

    static QStringList supportedServices();
    QString service() const;

    bool busy() const;
    QString sourceLanguage() const;
    QString targetLanguage() const;
    QString sourceText() const;
    QString detectedLanguage() const;
    QString translatedText() const;
    DictionaryModel *dictionary() const;

    Q_INVOKABLE void translate();

signals:
    void error(const QString &errorString) const;
    void busyChanged(bool busy);
    void fromLanguageChanged(const QString &sourceLanguage);
    void toLanguageChanged(const QString &targetLanguage);
    void sourceTextChanged(const QString &sourceText);
    void detectedLanguageChanged(const QString &detectedLanguage);
    void translatedTextChanged(const QString &translatedText);
    void dictionaryChanged();

public slots:
    void setSourceLanguage(const QString &sourceLanguage);
    void setTargetLanguage(const QString &targetLanguage);
    void setSourceText(const QString &sourceText);
    void requestFinished(QNetworkReply *reply);

private:
    QString m_service;

    bool m_busy;
    QString m_srcLang;
    QString m_trgtLang;
    QString m_srcText;
    QString m_detected;
    QString m_translation;
    DictionaryModel *m_dict;

    QNetworkAccessManager nam;
    QNetworkReply *networkReply;

    QSettings settings;

    void resetTranslation();
    void setBusy(bool busy);
    void setDetectedLanguage(const QString &detectedLanguage);
    void setTranslatedText(const QString &translatedText);
};

#endif // TRANSLATIONINTERFACE_H
