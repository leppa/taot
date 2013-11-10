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

#include "translationservice.h"

Language::Language()
    : displayName(TranslationService::tr("Unknown"))
{}

Language::Language(const QVariant info, const QString &name)
    : info(info), displayName(name)
{}

bool Language::operator ==(const Language &other)
{
    return info == other.info;
}

TranslationService::TranslationService(QObject *parent)
    : QObject(parent), m_error(tr("No error"))
{}

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
    m_translation.clear();
    m_detectedLanguage = Language();
}

QString TranslationService::translation() const
{
    return m_translation;
}

Language TranslationService::detectedLanguage() const
{
    return m_detectedLanguage;
}

QString TranslationService::errorString() const
{
    return m_error;
}

TranslationService::~TranslationService() {}
