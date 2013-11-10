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

#include "translationinterface.h"

#include <QScriptEngine>
#include <QScriptValueIterator>
#include <QDebug>

TranslationInterface::TranslationInterface(QObject *parent)
    : QObject(parent), m_service("Google"), m_busy(false), m_dict(new DictionaryModel()), networkReply(NULL)
{
    settings.beginGroup(m_service);
    m_srcLang = settings.value("SourceLanguage", "auto").toString();
    m_trgtLang = settings.value("TargetLanguage", "en").toString();
    settings.endGroup();
    connect(&nam, SIGNAL(finished(QNetworkReply*)), SLOT(onRequestFinished(QNetworkReply*)));
}

QString TranslationInterface::version()
{
    return qApp->applicationVersion();
}

bool TranslationInterface::busy() const
{
    return m_busy;
}

QString TranslationInterface::sourceLanguage() const
{
    return m_srcLang;
}

QString TranslationInterface::targetLanguage() const
{
    return m_trgtLang;
}

QString TranslationInterface::sourceText() const
{
    return m_srcText;
}

QString TranslationInterface::detectedLanguage() const
{
    return m_detected;
}

QString TranslationInterface::translatedText() const
{
    return m_translation;
}

DictionaryModel *TranslationInterface::dictionary() const
{
    return m_dict;
}

void TranslationInterface::translate()
{
    if (m_srcText.isEmpty()) {
        emit error(tr("Please, enter the source text"));
        return;
    }

    resetTranslation();

    setBusy(true);

    QUrl url("http://translate.google.com/translate_a/t?client=q");
    url.addQueryItem("hl", "en");
    url.addQueryItem("sl", m_srcLang);
    url.addQueryItem("tl", m_trgtLang);
    url.addQueryItem("text", m_srcText);
    networkReply = nam.get(QNetworkRequest(url));
}

void TranslationInterface::setSourceLanguage(const QString &from)
{
    if (m_srcLang == from)
        return;
    resetTranslation();
    m_srcLang = from;
    settings.setValue(m_service + "/SourceLanguage", m_srcLang);
    emit sourceLanguageChanged();
}

void TranslationInterface::setTargetLanguage(const QString &to)
{
    if (m_trgtLang == to)
        return;
    resetTranslation();
    m_trgtLang = to;
    settings.setValue(m_service + "/TargetLanguage", m_trgtLang);
    emit targetLanguageChanged();
}

void TranslationInterface::setSourceText(const QString &sourceText)
{
    if (m_srcText == sourceText)
        return;
    resetTranslation();
    m_srcText = sourceText;
    emit sourceTextChanged();
}

void TranslationInterface::onRequestFinished(QNetworkReply *reply)
{
    Q_ASSERT(reply == networkReply);
    networkReply = NULL;
    setBusy(false);

    if (reply->error() == QNetworkReply::OperationCanceledError) {
        // Operation was canceled by us, ignore this error.
        reply->deleteLater();
        return;
    } else if (reply->error() != QNetworkReply::NoError) {
        qWarning() << reply->errorString();
        emit error(reply->errorString());
        reply->deleteLater();
        return;
    }

    QString json;
    json.reserve(reply->size());
    json.append("(").append(QString::fromUtf8(reply->readAll())).append(")");

    QScriptEngine engine;
    if (!engine.canEvaluate(json)) {
        emit error(tr("Couldn't parse response from the server because of an error: \"%1\"")
                   .arg(tr("Can't evaluate JSON data")));
        return;
    }
    QScriptValue data = engine.evaluate(json);
    if (engine.hasUncaughtException()) {
        emit error(tr("Couldn't parse response from the server because of an error: \"%1\"")
                   .arg(engine.uncaughtException().toString()));
        return;
    }

    if (m_srcLang == "auto")
        setDetectedLanguage(data.property("src").toString());
    QString translation;
    QScriptValueIterator ti(data.property("sentences"));
    while (ti.hasNext()) {
        ti.next();
        translation.append(ti.value().property("trans").toString());
    }
    setTranslatedText(translation);

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

            // Extracting parts of speech (with revers translations)
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
                pos.reverseTranslations()->append(ei.value().property("word").toString(), rtrans);
            }
            m_dict->append(pos);
        }
    }
}

void TranslationInterface::resetTranslation()
{
    setTranslatedText(QString());
    setDetectedLanguage(QString());
    m_dict->clear();
    if (!networkReply)
        return;
    if (networkReply->isRunning())
        networkReply->abort();
}

void TranslationInterface::setBusy(bool busy)
{
    if (m_busy == busy)
        return;
    m_busy = busy;
    emit busyChanged();
}

void TranslationInterface::setDetectedLanguage(const QString &detectedLanguage)
{
    if (m_detected == detectedLanguage)
        return;
    m_detected = detectedLanguage;
    emit detectedLanguageChanged();
}

void TranslationInterface::setTranslatedText(const QString &translatedText)
{
    if (m_translation == translatedText)
        return;
    m_translation = translatedText;
    emit translatedTextChanged();
}
