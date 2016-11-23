#ifndef MICROSOFTTRANSLATOR_H
#define MICROSOFTTRANSLATOR_H

#include "jsontranslationservice.h"

#include <QTimer>
#include <QSslConfiguration>

class MicrosoftTranslator: public JsonTranslationService
{
    Q_OBJECT

public:
    static QString displayName();

    explicit MicrosoftTranslator(QObject *parent = 0);

    QString uid() const;
    bool targetLanguagesDependOnSourceLanguage() const;
    bool supportsTranslation() const;
    bool supportsDictionary() const;

    LanguageList sourceLanguages() const;
    LanguageList targetLanguages(const Language &sourceLanguage) const;
    LanguagePair defaultLanguagePair() const;
    QString getLanguageName(const QVariant &info) const;
    bool isAutoLanguage(const Language &lang) const;
    bool canSwapLanguages(const Language &first, const Language &second) const;

    bool translate(const Language &from, const Language &to, const QString &text);
    bool parseReply(const QByteArray &reply);

private slots:
    void onTokenTimeout();

private:
    bool checkReplyForErrors(QNetworkReply *reply);
    void requestToken();

    enum State {
        TokenRequestState,
        TranslationState
    };

    State m_state;
    QByteArray m_token;
    QTimer m_tokenTimeout;
    LanguageList m_sourceLanguages;
    LanguageList m_targetLanguages;
    LanguagePair m_defaultLanguagePair;
    QHash<QString, QString> m_langCodeToName;
    LanguagePair m_translationPair;
    QString m_sourceText;
    QSslConfiguration m_sslConfiguration;
};

#endif // MICROSOFTTRANSLATOR_H
