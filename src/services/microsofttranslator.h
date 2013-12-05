#ifndef MICROSOFTTRANSLATOR_H
#define MICROSOFTTRANSLATOR_H

#include "jsontranslationservice.h"

#include <QTimer>

class MicrosoftTranslator: public JsonTranslationService
{
    Q_OBJECT

public:
    static QString displayName();

    explicit MicrosoftTranslator(QObject *parent = 0);

    QString uid() const;
    bool targetLanguagesDependOnSourceLanguage() const;
    bool supportsDictionary() const;

    LanguageList sourceLanguages() const;
    LanguageList targetLanguages(const Language &sourceLanguage) const;
    LanguagePair defaultLanguagePair() const;
    QString getLanguageName(const QVariant &info) const;
    bool canSwapLanguages(const Language first, const Language second) const;

    bool translate(const Language &from, const Language &to, const QString &text);
    bool parseReply(const QByteArray &reply);

private slots:
    void onTokenTimeout();

private:
    bool checkReplyForErrors(QNetworkReply *reply);
    void requestToken();

    QString m_token;
    QTimer m_tokenTimeout;
    LanguageList m_sourceLanguages;
    LanguageList m_targetLanguages;
    LanguagePair m_defaultLanguagePair;
    QHash<QString, QString> m_langCodeToName;
    LanguagePair m_translationPair;
    QString m_sourceText;
};

#endif // MICROSOFTTRANSLATOR_H
