/*
 *  TAO Translator
 *  Copyright (C) 2013-2017  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
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

#include "translationservicesmodel.h"

TranslationServiceItem::TranslationServiceItem(int id, const QString &name, QObject *parent)
    : QObject(parent), m_id(id), m_name(name)
{}

int TranslationServiceItem::index() const
{
    return m_id;
}

QString TranslationServiceItem::name() const
{
    return m_name;
}

TranslationServicesModel::TranslationServicesModel(const QStringList &strings, QObject *parent)
    : QStringListModel(strings, parent)
{
#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    setRoleNames(roleNames());
#endif
}

QHash<int, QByteArray> TranslationServicesModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(Qt::DisplayRole, "name");
    return roles;
}

int TranslationServicesModel::count() const
{
    return rowCount();
}

QString TranslationServicesModel::get(int index) const
{
    return data(createIndex(index, 0), Qt::DisplayRole).toString();
}
