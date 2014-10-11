/*
 *  TAO Translator
 *  Copyright (C) 2013-2014  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
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

#ifndef GOOGLETRANSLATE_H
#define GOOGLETRANSLATE_H

#include "jsontranslationservice.h"

class DictionaryModel;
class GoogleTranslate: public JsonTranslationService
{
    Q_OBJECT

public:
    static QString displayName();

    explicit GoogleTranslate(DictionaryModel *dict, QObject *parent = 0);

    QString uid() const;
    bool targetLanguagesDependOnSourceLanguage() const;
    bool supportsTranslation() const;
    bool supportsDictionary() const;

    LanguageList sourceLanguages() const;
    LanguageList targetLanguages(const Language &sourceLanguage) const;
    LanguagePair defaultLanguagePair() const;
    QString getLanguageName(const QVariant &info) const;
    bool isAutoLanguage(const Language &lang) const;
    bool canSwapLanguages(const Language first, const Language second) const;

    bool translate(const Language &from, const Language &to, const QString &text);
    bool parseReply(const QByteArray &data);

private:
    DictionaryModel *m_dict;
    LanguageList m_sourceLanguages;
    LanguageList m_targetLanguages;
    LanguagePair m_defaultLanguagePair;
    QHash<QString, QString> m_langCodeToName;
};

#endif // GOOGLETRANSLATE_H
