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

#include "yandextranslationservice.h"

#include <QFile>
#include <QStringList>

YandexTranslationService::YandexTranslationService(QObject *parent)
    : JsonTranslationService(parent)
{
    QFile f;

    f.setFileName("://cacertificates/certum.ca.pem");
    f.open(QFile::ReadOnly);
    QSslCertificate cert(f.readAll());
    f.close();

    m_sslConfiguration = QSslConfiguration::defaultConfiguration();
    QList<QSslCertificate> cacerts = m_sslConfiguration.caCertificates();
    cacerts.append(cert);
    m_sslConfiguration.setCaCertificates(cacerts);
}

bool YandexTranslationService::targetLanguagesDependOnSourceLanguage() const
{
    return true;
}

LanguageList YandexTranslationService::sourceLanguages() const
{
    return m_sourceLanguages;
}

LanguageList YandexTranslationService::targetLanguages(const Language &sourceLanguage) const
{
    return m_targetLanguages.value(sourceLanguage.info.toString());
}

QString YandexTranslationService::getLanguageName(const QVariant &info) const
{
    //: Unknown language
    return m_langCodeToName.value(info.toString(),
                                  tr("Unknown (%1)", "Unknown language").arg(info.toString()));
}

bool YandexTranslationService::isAutoLanguage(const Language &lang) const
{
    return lang.info.toString().isEmpty();
}

bool YandexTranslationService::canSwapLanguages(const Language &first, const Language &second) const
{
    if (first.info.toString().isEmpty() || second.info.toString().isEmpty() || first == second)
        return false;

    return m_sourceLanguages.contains(second)
           && m_targetLanguages.value(second.info.toString()).contains(first);
}

bool YandexTranslationService::checkReplyForErrors(QNetworkReply *reply)
{
    switch (reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt()) {
    case 401:
    case 402:
    case 403:
    case 404:
    case 413:
    case 422:
    case 501:
        QVariant data = parseJson(reply->readAll());
        m_error = data.toMap().value("message").toString();
        return false;
    }

    return JsonTranslationService::checkReplyForErrors(reply);
}

void YandexTranslationService::loadLanguages(const QString &file, bool withAutodetect)
{
    if (withAutodetect) {
        m_sourceLanguages << Language("", tr("Autodetect"));
        m_langCodeToName.insert("", tr("Autodetect"));
    }

    QFile f(file);
    if (f.open(QFile::Text | QFile::ReadOnly)) {
        const QVariant data = parseJson(f.readAll());
        f.close();
        if (data.isValid()) {
            QVariantMapIterator langs(data.toMap().value("langs").toMap());
            while (langs.hasNext()) {
                langs.next();
                const QString code = langs.key();
                const QString name = langs.value().toString();

                m_langCodeToName.insert(code, name);
            }

            QSet<QString> duplicates;
            foreach (const QString &dirs, data.toMap().value("dirs").toStringList()) {
                const QStringList pair = dirs.split("-");

                if (!duplicates.contains(pair.at(0))) {
                    const QString code = pair.at(0);
                    const QString name = m_langCodeToName.value(pair.at(0));
                    m_sourceLanguages << Language(code, name);
                    m_targetLanguages[""] << Language(code, name);
                    duplicates.insert(pair.at(0));
                }
                m_targetLanguages[pair.at(0)] << Language(pair.at(1),
                                                          m_langCodeToName.value(pair.at(1)));
            }
        }
    }

    // Sort the languages alphabetically
    qSort(m_sourceLanguages);
    foreach (const QString &key, m_targetLanguages.keys()) {
        qSort(m_targetLanguages[key]);
    }

    if (m_sourceLanguages.contains(Language("", "")))
        m_defaultLanguagePair.first = Language("", m_langCodeToName.value(""));
    else
        m_defaultLanguagePair.first = m_sourceLanguages.first();

    if (m_targetLanguages.value(m_defaultLanguagePair.first.info
                                .toString()).contains(Language("en", "")))
        m_defaultLanguagePair.second = Language("en", m_langCodeToName.value("en"));
    else
        m_defaultLanguagePair.second = m_targetLanguages.value(m_defaultLanguagePair.first.info
                                                               .toString()).first();
}
