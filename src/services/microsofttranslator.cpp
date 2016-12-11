#include "microsofttranslator.h"

#include "apikeys.h"

#include <QFile>
#include <QCoreApplication>
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
    m_sslConfiguration = QSslConfiguration::defaultConfiguration();
    QList<QSslCertificate> cacerts(m_sslConfiguration.caCertificates());
    cacerts << loadSslCertificates(QLatin1String("://cacertificates/baltimore.ca.pem"));
    m_sslConfiguration.setCaCertificates(cacerts);

    m_tokenTimeout.setSingleShot(true);
    connect(&m_tokenTimeout, SIGNAL(timeout()), SLOT(onTokenTimeout()));

    m_sourceLanguages << Language("", commonString(AutodetectLanguageCommonString));
    m_langCodeToName.insert("", commonString(AutodetectLanguageCommonString));

    // TODO: Download actual list from
    // https://api.microsofttranslator.com/V2/Ajax.svc/GetLanguagesForTranslate
    // https://api.microsofttranslator.com/V2/Ajax.svc/GetLanguageNames
    QFile f(QLatin1String("://langs/ms.json"));
    if (f.open(QFile::Text | QFile::ReadOnly)) {
        const QVariant data = parseJson(f.readAll());
        f.close();
        if (data.isValid()) {
            QVariantMapIterator sl(data.toMap().value("text").toMap());
            while (sl.hasNext()) {
                sl.next();
                const QString code = sl.key();
                const QString name = sl.value().toMap().value("name").toString();
                Language lang(code, name);
                m_targetLanguages << lang;
                m_langCodeToName.insert(code, name);
            }
        }
    }

    qSort(m_targetLanguages);
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
    return m_langCodeToName.value(info.toString(), commonString(UnknownLanguageWithInfoCommonString)
                                                   .arg(info.toString()));
}

bool MicrosoftTranslator::isAutoLanguage(const Language &lang) const
{
    return lang.info.toString().isEmpty();
}

bool MicrosoftTranslator::canSwapLanguages(const Language &first, const Language &second) const
{
    return first != second && !first.info.toString().isEmpty() && !second.info.toString().isEmpty();
}

bool MicrosoftTranslator::translate(const Language &from, const Language &to, const QString &text)
{
    if (m_reply && m_reply->isRunning())
        m_reply->abort();

    m_translationPair = LanguagePair(from, to);
    if (m_token.isEmpty()) {
        m_sourceText = text;
        requestToken();
        return true;
    }

#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    QUrl query("https://api.microsofttranslator.com/v2/ajax.svc/GetTranslations");
#else
    QUrl url("https://api.microsofttranslator.com/v2/ajax.svc/GetTranslations");
    QUrlQuery query;
#endif
    query.addQueryItem("text", text);
    query.addQueryItem("from", from.info.toString());
    query.addQueryItem("to", to.info.toString());
    query.addQueryItem("maxTranslations", "1");

#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    QNetworkRequest request(query);
#else
    url.setQuery(query);
    QNetworkRequest request(url);
#endif
    request.setRawHeader("Authorization", m_token);
    request.setRawHeader("Accept", "application/json");
    request.setSslConfiguration(m_sslConfiguration);

    m_state = TranslationState;
    m_reply = m_nam.get(request);

    return true;
}

bool MicrosoftTranslator::parseReply(const QByteArray &reply)
{
    switch (m_state) {
    case TranslationState: {
        const QVariant data = parseJson(reply);
        if (!data.isValid())
            return false;

        if (data.type() == QVariant::Map) {
            const QVariantMap dataMap = data.toMap();

            if (dataMap.value("Translations").type() == QVariant::List) {
                const QVariantList translations = dataMap.value("Translations").toList();
                if (translations.count() < 1) {
                    m_error = commonString(EmptyResultCommonString).arg(displayName());
                    return true;
                }

                if (isAutoLanguage(m_translationPair.first)) {
                    const QString detected = dataMap.value("From").toString();
                    m_detectedLanguage = Language(detected, getLanguageName(detected));
                }

                m_translation = translations.at(0).toMap().value("TranslatedText").toString();

                return true;
            }

            if (data.toMap().value("error_description").type() == QVariant::String) {
                m_error = commonString(ErrorReturnedCommonString).arg(displayName(),
                                                                      data.toMap()
                                                                      .value("error_description")
                                                                      .toString());
            } else {
                m_error = commonString(UnexpectedResponseCommonString);
            }

            return false;
        } else if (data.type() == QVariant::String) {
            m_error = commonString(ErrorReturnedCommonString).arg(displayName(), data.toString());
            return false;
        }
    }

    case TokenRequestState:
        m_token = "Bearer " + reply;
        // Token is valid for 600 seconds. Clear it 30 seconds before the timeout.
        m_tokenTimeout.setInterval(570000);
        m_tokenTimeout.start();
        return translate(m_translationPair.first, m_translationPair.second, m_sourceText);

    default:
        m_error = commonString(UnexpectedResponseCommonString);
        return false;
    }
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
    QNetworkRequest request(QUrl("https://api.cognitive.microsoft.com/sts/v1.0/issueToken"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    request.setRawHeader("Accept", "application/jwt");
    request.setRawHeader("Ocp-Apim-Subscription-Key", MSTRANSLATOR_TEXT_API_KEY);

    m_state = TokenRequestState;
    m_reply = m_nam.post(request, QByteArray());
}
