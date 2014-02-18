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

#include "dictionarymodel.h"

#include "bb10/reversetranslationsmodel.h"

DictionaryPos::DictionaryPos(const QString &pos, const QStringList &translations)
    : m_pos(pos)
    , m_translations(translations)
    , m_reverse(new ReverseTranslations)
{
    // We can't delete m_reverse in destructor because when the object
    // is copied through copy constructor and original is deleted it
    // would invalidate m_reverse in both original and copied objects.
    // QSharedPointer takes care of this and deletes m_reverse only
    // when all copies of the object are deleted.
    ptr = QSharedPointer<ReverseTranslations>(m_reverse);
}

QString DictionaryPos::pos() const
{
    return m_pos;
}

QString DictionaryPos::translations(const QString separator) const
{
    return m_translations.join(separator);
}

QStringList &DictionaryPos::translations()
{
    return m_translations;
}

ReverseTranslations *DictionaryPos::reverseTranslations()
{
    return m_reverse;
}

DictionaryModel::DictionaryModel(QObject *parent)
    : bb::cascades::QMapListDataModel()
{
    setParent(parent);
}

void DictionaryModel::append(DictionaryPos &pos)
{
    QVariantMap map;
    map.insert("pos", pos.pos());
    map.insert("translations", pos.translations(tr(", ", "Separator for joining string lists"
                                                   " (don't forget space after comma).")));
    map.insert("reverseTranslations",
               QVariant::fromValue(new ReverseTranslationsModel(pos.reverseTranslations(), this)));

    bb::cascades::QMapListDataModel::append(map);
}
