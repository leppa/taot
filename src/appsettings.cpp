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

#include "appsettings.h"

#include "singlesettings.h"

#include <QDebug>

AppSettings::AppSettings(QObject *parent)
    : QObject(parent)
    , m_settings(SingleSettings::getInstance())
{
    connect(m_settings, SIGNAL(valueChanged(QString)), this, SIGNAL(valueChanged(QString)));
    connect(m_settings, SIGNAL(valueChanged(QString)), this, SLOT(onValueChanged(QString)));
}

void AppSettings::beginGroup(const QString &prefix)
{
    m_group.append(prefix);
    if (!m_group.endsWith("/"))
        m_group.append("/");
}

QString AppSettings::group() const
{
    return m_group.left(m_group.length() - 1);
}

void AppSettings::endGroup()
{
    m_group.clear();
}

bool AppSettings::contains(const QString &key) const
{
    return m_settings->contains(m_group + key);
}

void AppSettings::remove(const QString &key)
{
    m_settings->remove(m_group + key);
}

void AppSettings::setValue(const QString &key, const QVariant &value)
{
    m_settings->setValue(m_group + key, value);
}

QVariant AppSettings::value(const QString &key, const QVariant &defaultValue) const
{
    return m_settings->value(m_group + key, defaultValue);
}

void AppSettings::onValueChanged(const QString &key)
{
    // TODO
}
