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

#include "languagelistmodel.h"

LanguageItem::LanguageItem(const Language &language, int index, QObject *parent)
    : QObject(parent), m_language(language), m_index(index)
{}

Language LanguageItem::language() const
{
    return m_language;
}

QString LanguageItem::displayName() const
{
    return m_language.displayName;
}

QVariant LanguageItem::info() const
{
    return m_language.info;
}

int LanguageItem::index() const
{
    return m_index;
}

void LanguageItem::setIndex(int index)
{
    if (index == m_index)
        return;

    m_index = index;
    emit indexChanged();
}

LanguageListModel::LanguageListModel(QObject *parent)
    : QAbstractListModel(parent)
{
#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    setRoleNames(roleNames());
#endif
}

QHash<int, QByteArray> LanguageListModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(Qt::DisplayRole, "name");
    roles.insert(InfoRole, "info");
    return roles;
}

int LanguageListModel::count() const
{
    return m_languages.count();
}

int LanguageListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return count();
}

QVariant LanguageListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_languages.count())
        return QVariant();

    switch (role) {
    case Qt::DisplayRole:
        return m_languages.at(index.row()).displayName;
    case InfoRole:
        return m_languages.at(index.row()).info;
    default:
        return QVariant();
    }
}

void LanguageListModel::setLanguageList(const LanguageList &list)
{
    if (list == m_languages)
        return;

    beginResetModel();
    m_languages = list;
    endResetModel();

    emit countChanged();
}

Language LanguageListModel::get(int index) const
{
    if (index < 0 || index >= m_languages.count())
        return Language();

    return m_languages.at(index);
}

int LanguageListModel::indexOf(const Language language) const
{
    return m_languages.indexOf(language);
}

int LanguageListModel::indexOf(LanguageItem *language) const
{
    return indexOf(language->language());
}

QString LanguageListModel::displayNameOf(int index) const
{
    return data(createIndex(index, 0), Qt::DisplayRole).toString();
}
