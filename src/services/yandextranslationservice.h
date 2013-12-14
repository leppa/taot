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

#ifndef YANDEXTRANSLATIONSERVICE_H
#define YANDEXTRANSLATIONSERVICE_H

#include "jsontranslationservice.h"

#include <QSslConfiguration>

class YandexTranslationService : public JsonTranslationService
{
    Q_OBJECT

public:
    explicit YandexTranslationService(QObject *parent = 0);

    bool targetLanguagesDependOnSourceLanguage() const;
    LanguageList sourceLanguages() const;
    LanguageList targetLanguages(const Language &sourceLanguage) const;
    QString getLanguageName(const QVariant &info) const;
    bool canSwapLanguages(const Language first, const Language second) const;

    bool checkReplyForErrors(QNetworkReply *reply);

protected:
    void loadLanguages(const QString &file, bool withAutodetect = true);

    QSslConfiguration m_sslConfiguration;
    LanguageList m_sourceLanguages;
    QHash<QString, LanguageList> m_targetLanguages;
    LanguagePair m_defaultLanguagePair;
    QHash<QString, QString> m_langCodeToName;
};

#endif // YANDEXTRANSLATIONSERVICE_H
