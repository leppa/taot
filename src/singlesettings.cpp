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

#include "singlesettings.h"

#include <QCoreApplication>
#include <QSettings>

QAtomicPointer<SingleSettings> SingleSettings::m_instance;
QMutex SingleSettings::m_mutex;

SingleSettings *SingleSettings::getInstance()
{
    SingleSettings *tmp = m_instance.fetchAndAddAcquire(0);
    if (Q_UNLIKELY(!tmp)) {
        m_mutex.lock();
        if (!m_instance.fetchAndAddRelaxed(0)) {
            tmp = new SingleSettings(qApp);
            m_instance.fetchAndStoreRelease(tmp);
        }
        m_mutex.unlock();
    }
    return m_instance;
}

bool SingleSettings::contains(const QString &key) const
{
    return m_settings->contains(key);
}

void SingleSettings::remove(const QString &key)
{
    if (!m_settings->contains(key))
        return;

    m_settings->remove(key);
    emit valueChanged(key);
}

void SingleSettings::setValue(const QString &key, const QVariant &value)
{
    const QVariant val = m_settings->value(key);

    if (val == value)
        return;

    m_settings->setValue(key, value);
    emit valueChanged(key);
}

QVariant SingleSettings::value(const QString &key, const QVariant &defaultValue) const
{
    return m_settings->value(key, defaultValue);
}

SingleSettings::SingleSettings(QObject *parent)
    : QObject(parent)
#ifdef Q_OS_SAILFISH
    , m_settings(new QSettings("harbour-taot", "taot", qApp))
#else
    , m_settings(new QSettings(QCoreApplication::organizationName(), "taot", qApp))
#endif
{}
