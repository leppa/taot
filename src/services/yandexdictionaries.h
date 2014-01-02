/*
 *  The Advanced Online Translator
 *  Copyright (C) 2013-2014  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
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

#ifndef YANDEXDICTIONARIES_H
#define YANDEXDICTIONARIES_H

#include "yandextranslationservice.h"

#include <QSslConfiguration>

class DictionaryModel;
class YandexDictionaries: public YandexTranslationService
{
    Q_OBJECT

public:
    static QString displayName();

    explicit YandexDictionaries(DictionaryModel *dict, QObject *parent = 0);

    QString uid() const;
    bool supportsTranslation() const;
    bool supportsDictionary() const;

    LanguagePair defaultLanguagePair() const;

    bool translate(const Language &from, const Language &to, const QString &text);
    bool parseReply(const QByteArray &reply);

private:
    DictionaryModel *m_dict;
};

#endif // YANDEXDICTIONARIES_H
