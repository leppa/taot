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

#ifndef TRANSLATIONSERVICE_H
#define TRANSLATIONSERVICE_H

#include <QObject>
#include <QString>
#include <QVariant>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QSslCertificate>

struct Language
{
    QVariant info;
    QString displayName;

    Language();
    explicit Language(const QVariant info, const QString &name);

    bool operator ==(const Language &other) const;
    bool operator !=(const Language &other) const;
    bool operator <(const Language &other) const;
};
typedef QPair<Language, Language> LanguagePair;
typedef QList<Language> LanguageList;

typedef QPair<QString, QString> StringPair;

class TranslationService: public QObject
{
    Q_OBJECT

public:
    explicit TranslationService(QObject *parent = 0);

    virtual QString uid() const = 0;
    virtual bool targetLanguagesDependOnSourceLanguage() const = 0;
    virtual bool supportsTranslation() const = 0;
    virtual bool supportsDictionary() const = 0;

    virtual LanguageList sourceLanguages() const = 0;
    virtual LanguageList targetLanguages(const Language &sourceLanguage) const = 0;
    virtual LanguagePair defaultLanguagePair() const = 0;
    virtual QString getLanguageName(const QVariant &info) const = 0;
    virtual bool isAutoLanguage(const Language &lang) const = 0;
    virtual bool canSwapLanguages(const Language &first, const Language &second) const = 0;
    virtual QString serializeLanguageInfo(const QVariant &info) const;
    virtual QVariant deserializeLanguageInfo(const QString &info) const;

    virtual void clear();
    virtual bool translate(const Language &from, const Language &to, const QString &text) = 0;
    virtual void cancelTranslation();
    virtual bool parseReply(const QByteArray &reply) = 0;

    virtual QString translation() const;
    virtual StringPair transcription() const;
    virtual StringPair translit() const;
    virtual Language detectedLanguage() const;

    virtual QString errorString() const;

    virtual ~TranslationService();

protected:
    virtual bool checkReplyForErrors(QNetworkReply *reply);
    QList<QSslCertificate> loadSslCertificates(const QStringList &paths) const;
    QList<QSslCertificate> loadSslCertificates(const QString &path) const;

private slots:
    void onNetworkReply(QNetworkReply *reply);
    void onSslErrors(QNetworkReply *reply,const QList<QSslError> &errors);

signals:
    void translationFinished(bool success);

protected:
    QNetworkAccessManager m_nam;
    QNetworkReply *m_reply;

    QString m_error;
    QString m_sslErrors;
    QString m_translation;
    StringPair m_transcription;
    StringPair m_translit;
    Language m_detectedLanguage;
};

enum CommonString {
    AutodetectLanguageCommonString,
    UnknownLanguageCommonString,
    UnknownLanguageWithInfoCommonString,
    NoErrorCommonString,
    ErrorReturnedCommonString,
    UnexpectedResponseCommonString,
    EmptyResultCommonString
};

inline QString commonString(CommonString id)
{
    switch (id) {
    case AutodetectLanguageCommonString:
        //: As in "Automatically detect language"
        return TranslationService::tr("Autodetect", "Automatically detect language");
    case UnknownLanguageCommonString:
        //: Unknown language
        return TranslationService::tr("Unknown", "Unknown language");
    case UnknownLanguageWithInfoCommonString:
        //: Unknown language
        return TranslationService::tr("Unknown (%1)", "Unknown language");
    case NoErrorCommonString:
        return TranslationService::tr("No error");
    case ErrorReturnedCommonString:
        return TranslationService::tr("%1 service returned an error: \"%2\"");
    case UnexpectedResponseCommonString:
        return TranslationService::tr("Unexpected response from the server");
    case EmptyResultCommonString:
        return TranslationService::tr("Service %1 was unable to translate the text");
    default:
        return QString();
    }
}

#endif // TRANSLATIONSERVICE_H
