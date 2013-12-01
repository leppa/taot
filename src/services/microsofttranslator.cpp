#include "microsofttranslator.h"

#include "apikeys.h"

#include <QFile>
#include <QCoreApplication>
#include <QScriptValueIterator>

QString MicrosoftTranslator::displayName()
{
    return tr("Microsoft Translator");
}

#include <QDebug>

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
    QFile f;
#ifdef Q_OS_BLACKBERRY
    f.setFileName(QCoreApplication::applicationDirPath() + QLatin1String("/qml/langs.ms.json"));
#elif defined(MEEGO_EDITION_HARMATTAN)
    QDir dir(QCoreApplication::applicationDirPath());
    dir.cdUp();
    f.setFileName(dir.filePath(QLatin1String("qml/langs.ms.json")));
#else
    f.setFileName(QLatin1String("qml/langs.ms.json"));
#endif
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
    return m_langCodeToName.value(info.toString(), tr("Unknown (%1)").arg(info.toString()));
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

    QUrl url("http://api.microsofttranslator.com/V2/Ajax.svc/Translate");
    url.addQueryItem("text", text);
    url.addQueryItem("from", from.info.toString());
    url.addQueryItem("to", to.info.toString());

    QNetworkRequest request(url);
    request.setRawHeader("Authorization", m_token.toAscii());

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
    QUrl url;
    url.addQueryItem("grant_type", "client_credentials");
    url.addQueryItem("client_id", "TheAdvancedOnlineTranslator");
    url.addQueryItem("client_secret", BINGTRANSLATOR_API_KEY);
    url.addQueryItem("scope", "http://api.microsofttranslator.com");

    QNetworkRequest request(QUrl("https://datamarket.accesscontrol.windows.net/v2/OAuth2-13"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");

    m_reply = m_nam.post(request, url.encodedQuery());
}
