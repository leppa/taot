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

#include "translationservice.h"

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QDebug>

Language::Language()
    //: Unknown language
    : displayName(TranslationService::tr("Unknown", "Unknown language"))
{}

Language::Language(const QVariant info, const QString &name)
    : info(info), displayName(name)
{}

bool Language::operator ==(const Language &other) const
{
    return info == other.info;
}

bool Language::operator !=(const Language &other) const
{
    return !operator ==(other);
}

bool Language::operator <(const Language &other) const
{
    // Autodetect's info is usually an invalid QVariant, empty
    // string or "auto". Always put it on top of the list.
    if (!info.isValid() || info == "" || info == "auto")
        return true;
    else if (!other.info.isValid() || other.info == "" || other.info == "auto")
        return false;
    else
        return displayName < other.displayName;
}

TranslationService::TranslationService(QObject *parent)
    : QObject(parent), m_reply(NULL), m_error(commonString(NoErrorCommonString))
{
    connect(&m_nam, SIGNAL(finished(QNetworkReply*)), SLOT(onNetworkReply(QNetworkReply*)));
}

QString TranslationService::serializeLanguageInfo(const QVariant &info) const
{
    return info.toString();
}

QVariant TranslationService::deserializeLanguageInfo(const QString &info) const
{
    return QVariant(info);
}

void TranslationService::clear()
{
    m_error.clear();
    m_translation.clear();
    m_transcription = StringPair();
    m_translit = StringPair();
    m_detectedLanguage = Language();
}

void TranslationService::cancelTranslation()
{
    if (m_reply && m_reply->isRunning())
        m_reply->abort();
}

QString TranslationService::translation() const
{
    return m_translation;
}

StringPair TranslationService::transcription() const
{
    return m_transcription;
}

StringPair TranslationService::translit() const
{
    return m_translit;
}

Language TranslationService::detectedLanguage() const
{
    return m_detectedLanguage;
}

QString TranslationService::errorString() const
{
    return m_error;
}

TranslationService::~TranslationService()
{}

bool TranslationService::checkReplyForErrors(QNetworkReply *reply)
{
    if (reply->error() == QNetworkReply::OperationCanceledError) {
        // Operation was canceled by us, ignore this error.
        reply->deleteLater();
        return false;
    }

    if (reply->error() != QNetworkReply::NoError) {
        qWarning() << reply->errorString();
        m_error = reply->errorString();
        reply->deleteLater();
        return false;
    }

    return true;
}

void TranslationService::onNetworkReply(QNetworkReply *reply)
{
    if (reply != m_reply) {
        // Reply not for the latest request. Ignore it.
        reply->deleteLater();
        return;
    }

    m_reply = NULL;

    if (!checkReplyForErrors(reply)) {
        emit translationFinished();
        return;
    }

    parseReply(reply->readAll());
    reply->deleteLater();

    emit translationFinished();
}
