/*
 *  TAO Translator
 *  Copyright (C) 2013-2014  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
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

struct Language
{
    QVariant info;
    QString displayName;

    Language();
    explicit Language(const QVariant info, const QString &name);

    bool operator ==(const Language &other) const;
    bool operator <(const Language &other) const;
};
typedef QPair<Language, Language> LanguagePair;
typedef QList<Language> LanguageList;

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
    virtual bool canSwapLanguages(const Language first, const Language second) const = 0;
    virtual QString serializeLanguageInfo(const QVariant &info) const;
    virtual QVariant deserializeLanguageInfo(const QString &info) const;

    virtual void clear();
    virtual bool translate(const Language &from, const Language &to, const QString &text) = 0;
    virtual void cancelTranslation();
    virtual bool parseReply(const QByteArray &reply) = 0;

    virtual QString translation() const;
    virtual Language detectedLanguage() const;

    virtual QString errorString() const;

    virtual ~TranslationService();

protected:
    virtual bool checkReplyForErrors(QNetworkReply *reply);

private slots:
    void onNetworkReply(QNetworkReply *reply);

signals:
    void translationFinished();

protected:
    QNetworkAccessManager m_nam;
    QNetworkReply *m_reply;

    QString m_error;
    QString m_translation;
    Language m_detectedLanguage;
};

#endif // TRANSLATIONSERVICE_H
