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

#include "googletranslate.h"

#include <QScriptEngine>
#include <QScriptValue>
#include <QScriptValueIterator>
#include <QFile>
#include <QXmlStreamReader>

QString GoogleTranslate::displayName()
{
    return tr("Google Translate");
}

GoogleTranslate::GoogleTranslate(DictionaryModel *dict, QObject *parent)
    : JsonTranslationService(parent)
    , m_dict(dict)
{
    // TODO: Download actual list from
    // http://translate.googleapis.com/translate_a/l?client=q&hl=en
    QFile f(QLatin1String("://langs/google.json"));
    if (f.open(QFile::Text | QFile::ReadOnly)) {
        QScriptValue data = parseJson(f.readAll());
        f.close();
        if (!data.isError()) {
            QScriptValueIterator sl(data.property("sl"));
            while (sl.hasNext()) {
                sl.next();
                const QString code = sl.name();
                const QString name = sl.value().toString();
                Language lang(code, name);
                m_sourceLanguages << lang;
                m_langCodeToName.insert(code, name);
            }

            QScriptValueIterator tl(data.property("tl"));
            while (tl.hasNext()) {
                tl.next();
                const QString code = tl.name();
                const QString name = tl.value().toString();
                Language lang(code, name);
                m_targetLanguages << lang;
                m_langCodeToName.insert(code, name);
            }
        }
    }

    if (m_langCodeToName.contains("auto"))
        m_defaultLanguagePair.first = Language("auto", m_langCodeToName.value("auto"));
    else
        m_defaultLanguagePair.first = m_sourceLanguages.first();

    if (m_langCodeToName.contains("en"))
        m_defaultLanguagePair.second = Language("en", m_langCodeToName.value("en"));
    else
        m_defaultLanguagePair.second = m_targetLanguages.first();
}

QString GoogleTranslate::uid() const
{
    return "GoogleTranslate";
}

bool GoogleTranslate::targetLanguagesDependOnSourceLanguage() const
{
    return false;
}

bool GoogleTranslate::supportsTranslation() const
{
    return true;
}

bool GoogleTranslate::supportsDictionary() const
{
    return true;
}

LanguageList GoogleTranslate::sourceLanguages() const
{
    return m_sourceLanguages;
}

LanguageList GoogleTranslate::targetLanguages(const Language &) const
{
    return m_targetLanguages;
}

LanguagePair GoogleTranslate::defaultLanguagePair() const
{
    return m_defaultLanguagePair;
}

QString GoogleTranslate::getLanguageName(const QVariant &info) const
{
    return m_langCodeToName.value(info.toString(), tr("Unknown (%1)").arg(info.toString()));
}

bool GoogleTranslate::canSwapLanguages(const Language first, const Language second) const
{
    return first.info.toString() != "auto" && second.info.toString() != "auto";
}

bool GoogleTranslate::translate(const Language &from, const Language &to, const QString &text)
{
    QUrl url("http://translate.google.com/translate_a/t");
    url.addQueryItem("client", "q");
    url.addQueryItem("hl", "en");
    url.addQueryItem("sl", from.info.toString());
    url.addQueryItem("tl", to.info.toString());
    url.addQueryItem("text", text);

    m_reply = m_nam.get(QNetworkRequest(url));

    return true;
}

bool GoogleTranslate::parseReply(const QByteArray &reply)
{
    QString json;
    json.reserve(reply.size());
    json.append("(").append(reply).append(")");

    const QScriptValue data = parseJson(json);
    if (!data.isValid())
        return false;

    const QString detected = data.property("src").toString();
    m_detectedLanguage = Language(detected, getLanguageName(detected));

    m_translation.clear();
    QScriptValueIterator ti(data.property("sentences"));
    while (ti.hasNext()) {
        ti.next();
        m_translation.append(ti.value().property("trans").toString());
    }

    m_dict->clear();
    if (data.property("dict").isArray()) {
        QScriptValueIterator di(data.property("dict"));
        while (di.hasNext()) {
            di.next();
            if (di.flags() & QScriptValue::SkipInEnumeration)
                continue;
            // Extracting translations
            QScriptValueIterator ti(di.value().property("terms"));
            QStringList trans;
            while (ti.hasNext()) {
                ti.next();
                if (ti.flags() & QScriptValue::SkipInEnumeration)
                    continue;
                trans << ti.value().toString();
            }

            // Extracting parts of speech (with reverse translations)
            QScriptValueIterator ei(di.value().property("entry"));
            DictionaryPos pos(di.value().property("pos").toString(), trans);
            while (ei.hasNext()) {
                ei.next();
                if (ei.flags() & QScriptValue::SkipInEnumeration)
                    continue;

                // Extracting reverse translations
                QScriptValueIterator rti(ei.value().property("reverse_translation"));
                QStringList rtrans;
                while (rti.hasNext()) {
                    rti.next();
                    if (rti.flags() & QScriptValue::SkipInEnumeration)
                        continue;
                    rtrans << rti.value().toString();
                }
                pos.reverseTranslations()->append(ei.value().property("word").toString(),
                                                  QStringList(),
                                                  rtrans);
            }
            m_dict->append(pos);
        }
    }

    return true;
}
