/*
 *  The Advanced Online Translator
 *  Copyright (C) 2013-2014  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
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

#include <QFile>
#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
#   include <QUrlQuery>
#endif

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
        QVariant data = parseJson(f.readAll());
        f.close();
        if (data.isValid()) {
            QVariantMapIterator sl(data.toMap().value("sl").toMap());
            while (sl.hasNext()) {
                sl.next();
                const QString code = sl.key();
                const QString name = sl.value().toString();
                Language lang(code, name);
                m_sourceLanguages << lang;
                m_langCodeToName.insert(code, name);
            }

            QVariantMapIterator tl(data.toMap().value("tl").toMap());
            while (tl.hasNext()) {
                tl.next();
                const QString code = tl.key();
                const QString name = tl.value().toString();
                Language lang(code, name);
                m_targetLanguages << lang;
                m_langCodeToName.insert(code, name);
            }
        }
    }

    qSort(m_sourceLanguages);
    qSort(m_targetLanguages);

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
    return m_langCodeToName.value(info.toString(),
                                  tr("Unknown (%1)", "Unknown language").arg(info.toString()));
}

bool GoogleTranslate::canSwapLanguages(const Language first, const Language second) const
{
    return first.info.toString() != "auto" && second.info.toString() != "auto";
}

bool GoogleTranslate::translate(const Language &from, const Language &to, const QString &text)
{
#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    QUrl query("http://translate.google.com/translate_a/t");
#else
    QUrl url("http://translate.google.com/translate_a/t");
    QUrlQuery query;
#endif
    query.addQueryItem("client", "q");
    query.addQueryItem("hl", "en");
    query.addQueryItem("sl", from.info.toString());
    query.addQueryItem("tl", to.info.toString());
    query.addQueryItem("text", text);
#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    m_reply = m_nam.get(QNetworkRequest(query));
#else
    url.setQuery(query);
    m_reply = m_nam.get(QNetworkRequest(url));
#endif

    return true;
}

bool GoogleTranslate::parseReply(const QByteArray &reply)
{
    const QVariant data = parseJson(reply);
    if (!data.isValid())
        return false;

    const QString detected = data.toMap().value("src").toString();
    m_detectedLanguage = Language(detected, getLanguageName(detected));

    m_translation.clear();
    foreach (const QVariant &ti, data.toMap().value("sentences").toList()) {
        m_translation.append(ti.toMap().value("trans").toString());
    }

    m_dict->clear();
    if (data.toMap().value("dict").type() == QVariant::List) {
        foreach (const QVariant &di, data.toMap().value("dict").toList()) {
            // Extracting translations
            QStringList trans = di.toMap().value("terms").toStringList();

            // Extracting parts of speech (with reverse translations)
            DictionaryPos pos(di.toMap().value("pos").toString(), trans);
            foreach (const QVariant &ei, di.toMap().value("entry").toList()) {
                QStringList rtrans = ei.toMap().value("reverse_translation").toStringList();
                pos.reverseTranslations()->append(ei.toMap().value("word").toString(),
                                                  QStringList(),
                                                  rtrans);
            }
            m_dict->append(pos);
        }
    }

    return true;
}
