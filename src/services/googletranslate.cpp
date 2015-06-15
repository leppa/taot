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

#include "googletranslate.h"
#ifdef Q_OS_BLACKBERRY
#   include "bb10/dictionarymodel.h"
#   include "bb10/reversetranslationsmodel.h"
#else
#   include "dictionarymodel.h"
#endif

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
    return m_langCodeToName.value(info.toString(), commonString(UnknownLanguageWithInfoCommonString)
                                                   .arg(info.toString()));
}

bool GoogleTranslate::isAutoLanguage(const Language &lang) const
{
    return lang.info.toString() == "auto";
}

bool GoogleTranslate::canSwapLanguages(const Language &first, const Language &second) const
{
    return first != second && first.info.toString() != "auto" && second.info.toString() != "auto";
}

bool GoogleTranslate::translate(const Language &from, const Language &to, const QString &text)
{
#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    QUrl query("https://translate.google.com/translate_a/single");
    QUrl dataQuery;
#else
    QUrl url("https://translate.google.com/translate_a/single");
    QUrlQuery query, dataQuery;
#endif
    query.addQueryItem("client", "q");
    query.addQueryItem("hl", "en");
    query.addQueryItem("sl", from.info.toString());
    query.addQueryItem("tl", to.info.toString());
    query.addQueryItem("ie", "UTF-8");
    query.addQueryItem("oe", "UTF-8");
    // `dt` specifies what to return in the response
    query.addQueryItem("dt", "t"); // Translation
//    query.addQueryItem("dt", "at"); // Alternate translations
    query.addQueryItem("dt", "bd"); // Dictionary (with reverse translations and articles)
    query.addQueryItem("dt", "rm"); // Transliteration
//    query.addQueryItem("dt", "md"); // Definitions of source word
//    query.addQueryItem("dt", "ss"); // Source text synonyms
//    query.addQueryItem("dt", "ex"); // Examples
//    query.addQueryItem("dt", "rw"); // "See also" list
//    query.addQueryItem("dt", "ld"); // Unknown
//    query.addQueryItem("dt", "qca"); // Unknown
//    query.addQueryItem("ssel", "3");
//    query.addQueryItem("tsel", "0");
//    query.addQueryItem("otf", "1");

    dataQuery.addQueryItem("q", text);

#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    QNetworkRequest request(query);
    const QByteArray data(dataQuery.encodedQuery());
#else
    url.setQuery(query);
    QNetworkRequest request(url);
    const QByteArray data(dataQuery.toString(QUrl::FullyEncoded).toUtf8());
#endif
    request.setHeader(QNetworkRequest::ContentTypeHeader,
                      "application/x-www-form-urlencoded;charset=UTF-8");
    m_reply = m_nam.post(request, data);

    return true;
}

bool GoogleTranslate::parseReply(const QByteArray &reply)
{
#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
    // JSON coming from Google is invalid due to sequences
    // like ",,". Replacing all ",," with ",null," allows
    // us to parse JSON with QJsonDocument.
    QString json = QString::fromUtf8(reply);
    json.replace(QRegExp(",(?=,)"), ",null");
    json.replace(",]", ",null]");
    json.replace("[,", "[null,");
    const QVariant data = parseJson(json.toUtf8());
#else
    const QVariant data = parseJson(reply);
#endif

    if (!data.isValid() || data.type() != QVariant::List)
        return false;

    const QVariantList dl = data.toList();
    if (dl.isEmpty()) {
        m_error = commonString(EmptyResultCommonString).arg(displayName());
        return false;
    }

    const QString detected = dl.value(2).toString();
    m_detectedLanguage = Language(detected, getLanguageName(detected));

    m_translation.clear();
    m_translit = StringPair();
    foreach (const QVariant &ti, dl.value(0).toList()) {
        const QVariantList tr = ti.toList();
        if (!tr.value(0).isNull())
            m_translation.append(tr.value(0).toString());
        if (!tr.value(2).isNull())
            m_translit.second.append(tr.value(2).toString());
        if (!tr.value(3).isNull())
            m_translit.first.append(tr.value(3).toString());
    }

    m_dict->clear();
    if (dl.value(1).type() == QVariant::List) {
        foreach (const QVariant &di, dl.value(1).toList()) {
            const QVariantList dil = di.toList();

            // Translations
            const QStringList trans = dil.value(1).toStringList();
            // Part of speech
            DictionaryPos pos(dil.value(0).toString(), trans);
            // Reverse translations
            foreach (const QVariant &ei, dil.value(2).toList()) {
                const QVariantList eil = ei.toList();

                // Word from translations for which reverse translations are provided
                QString word = eil.value(0).toString();
                // Reverse translations for the aforementioned word
                const QStringList rtrans = eil.value(1).toStringList();
                // Article for the aforementioned word (if provided)
                if (!eil.value(4).toString().isEmpty())
                    word.prepend(eil.value(4).toString() + " ");

                pos.reverseTranslations()->append(word, QStringList(), rtrans);
            }
            m_dict->append(pos);
        }
    }

    return true;
}
