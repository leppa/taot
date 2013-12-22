#include "microsofttranslator.h"

#include "apikeys.h"

#include <QFile>
#include <QCoreApplication>
#include <QScriptValueIterator>
#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
#   include <QUrlQuery>
#endif

QString MicrosoftTranslator::displayName()
{
    return tr("Microsoft Translator");
}

MicrosoftTranslator::MicrosoftTranslator(QObject *parent)
    : JsonTranslationService(parent)
{
    m_tokenTimeout.setSingleShot(true);
    connect(&m_tokenTimeout, SIGNAL(timeout()), SLOT(onTokenTimeout()));

    m_sourceLanguages << Language("", tr("Autodetect"));
    m_langCodeToName.insert("", tr("Autodetect"));

    // TODO: Download actual list from
    // http://api.microsofttranslator.com/V2/Ajax.svc/GetLanguagesForTranslate
    // http://api.microsofttranslator.com/V2/Ajax.svc/GetLanguageNames
    QFile f(QLatin1String("://langs/ms.json"));
    if (f.open(QFile::Text | QFile::ReadOnly)) {
        QScriptValue data = parseJson(f.readAll());
        f.close();
        if (!data.isError()) {
            QScriptValueIterator sl(data);
            while (sl.hasNext()) {
                sl.next();
                const QString code = sl.name();
                const QString name = sl.value().toString();
                Language lang(code, name);
                m_targetLanguages << lang;
                m_langCodeToName.insert(code, name);
            }
        }
    }

    m_sourceLanguages << m_targetLanguages;

    if (m_langCodeToName.contains(""))
        m_defaultLanguagePair.first = Language("", m_langCodeToName.value(""));
    else
        m_defaultLanguagePair.first = m_sourceLanguages.first();

    if (m_langCodeToName.contains("en"))
        m_defaultLanguagePair.second = Language("en", m_langCodeToName.value("en"));
    else
        m_defaultLanguagePair.second = m_targetLanguages.first();
}

QString MicrosoftTranslator::uid() const
{
    return "MicrosoftTranslator";
}

bool MicrosoftTranslator::targetLanguagesDependOnSourceLanguage() const
{
    return false;
}

bool MicrosoftTranslator::supportsTranslation() const
{
    return true;
}

bool MicrosoftTranslator::supportsDictionary() const
{
    return false;
}

LanguageList MicrosoftTranslator::sourceLanguages() const
{
    return m_sourceLanguages;
}

LanguageList MicrosoftTranslator::targetLanguages(const Language &) const
{
    return m_targetLanguages;
}

LanguagePair MicrosoftTranslator::defaultLanguagePair() const
{
    return m_defaultLanguagePair;
}

QString MicrosoftTranslator::getLanguageName(const QVariant &info) const
{
    return m_langCodeToName.value(info.toString(),
                                  tr("Unknown (%1)", "Unknown language").arg(info.toString()));
}

bool MicrosoftTranslator::canSwapLanguages(const Language first, const Language second) const
{
    return !first.info.toString().isEmpty() && !second.info.toString().isEmpty();
}

bool MicrosoftTranslator::translate(const Language &from, const Language &to, const QString &text)
{
    if (m_reply && m_reply->isRunning())
        m_reply->abort();

    if (m_token.isEmpty()) {
        m_translationPair = LanguagePair(from, to);
        m_sourceText = text;
        requestToken();
        return true;
    }

#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    QUrl query("http://api.microsofttranslator.com/V2/Ajax.svc/Translate");
#else
    QUrl url("http://api.microsofttranslator.com/V2/Ajax.svc/Translate");
    QUrlQuery query;
#endif
    query.addQueryItem("text", text);
    query.addQueryItem("from", from.info.toString());
    query.addQueryItem("to", to.info.toString());

#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    QNetworkRequest request(query);
#else
    url.setQuery(query);
    QNetworkRequest request(url);
#endif
    request.setRawHeader("Authorization", m_token.toLatin1());

    m_reply = m_nam.get(request);

    return true;
}

bool MicrosoftTranslator::parseReply(const QByteArray &reply)
{
    QString json;
    json.reserve(reply.size());
    json.append("(").append(reply).append(")");

    const QScriptValue data = parseJson(json);
    if (!data.isValid())
        return false;

    if (data.isString() || data.isArray()) {
        m_translation = data.toString();
        return true;
    }

    if (data.isObject()) {
        if (data.property("access_token").isString()) {
            m_token = "Bearer " + data.property("access_token").toString();
            // Clear token 30 secs before the timeout. Just to be sure :-)
            m_tokenTimeout.setInterval(1000 * (data.property("expires_in").toInt32() - 30));
            m_tokenTimeout.start();
            return translate(m_translationPair.first, m_translationPair.second, m_sourceText);
        }

        if (data.property("error_description").isString()) {
            m_error = tr("Server returned an error: \"%1\"").arg(data.property("error_description")
                                                             .toString());
        } else {
            m_error = tr("Unexpected response from the server");
        }

        return false;
    }

    m_error = tr("Unexpected response from the server");
    return false;
}

void MicrosoftTranslator::onTokenTimeout()
{
    // The token has expired. Clear it so it's refreshed on next translation.
    m_token.clear();
}

bool MicrosoftTranslator::checkReplyForErrors(QNetworkReply *reply)
{
    if (reply->attribute(QNetworkRequest::HttpStatusCodeAttribute) == 400)
        return true;

    return JsonTranslationService::checkReplyForErrors(reply);
}

void MicrosoftTranslator::requestToken()
{
#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    QUrl query;
#else
    QUrlQuery query;
#endif
    query.addQueryItem("grant_type", "client_credentials");
    query.addQueryItem("client_id", BINGTRANSLATOR_CLIENT_ID);
    query.addQueryItem("client_secret", BINGTRANSLATOR_API_KEY);
    query.addQueryItem("scope", "http://api.microsofttranslator.com");

    QNetworkRequest request(QUrl("https://datamarket.accesscontrol.windows.net/v2/OAuth2-13"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");

#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    m_reply = m_nam.post(request, query.encodedQuery());
#else
    m_reply = m_nam.post(request, query.query(QUrl::FullyEncoded).toUtf8());
#endif
}
