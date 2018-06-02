/*
 *  TAO Translator
 *  Copyright (C) 2013-2018  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
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

#include "dictionarymodel.h"

DictionaryPos::DictionaryPos(const QString &pos, const QStringList &translations)
    : m_pos(pos), m_translations(translations), m_reverse(new ReverseTranslationsModel())
{
    // We can't delete m_reverse in destructor because when the object
    // is copied through copy constructor and original is deleted it
    // would invalidate m_reverse in both original and copied objects.
    // QSharedPointer takes care of this and deletes m_reverse only
    // when all copies of the object are deleted.
    ptr = QSharedPointer<ReverseTranslationsModel>(m_reverse);
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

ReverseTranslationsModel *DictionaryPos::reverseTranslations() const
{
    return m_reverse;
}

DictionaryModel::DictionaryModel(QObject *parent) :
    QAbstractListModel(parent)
{
#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    setRoleNames(roleNames());
#endif
}

QHash<int, QByteArray> DictionaryModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[PosRole] = "pos";
    roles[TranslationsRole] = "translations";
    roles[ReverseTranslationsRole] = "reverseTranslations";
    return roles;
}

int DictionaryModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_dict.count();
}

QVariant DictionaryModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || (index.row() < 0) || (index.row() > m_dict.count()))
        return QVariant();

    switch (role) {
    case PosRole:
        return m_dict.at(index.row()).pos();
    case TranslationsRole:
        //: Separator for joining string lists (don't forget space after comma)
        return m_dict.at(index.row()).translations(tr(", "));
    case ReverseTranslationsRole:
        return QVariant::fromValue(m_dict.at(index.row()).reverseTranslations());
    }

    return QVariant();
}

void DictionaryModel::append(const DictionaryPos &pos)
{
    emit beginInsertRows(QModelIndex(), m_dict.count(), m_dict.count());
    m_dict.append(pos);
    emit endInsertRows();
}

void DictionaryModel::clear()
{
    emit beginRemoveRows(QModelIndex(), 0, m_dict.count() - 1);
    m_dict.clear();
    emit endRemoveRows();
}
