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

#include <QMetaProperty>
#include <QStringList>

AppSettings::AppSettings(QObject *parent)
    : QObject(parent)
    , m_componentComplete(false)
    , m_capitalizeFirst(true)
    , m_settings(SingleSettings::getInstance())
{
    connect(m_settings, SIGNAL(valueChanged(QString)), this, SIGNAL(valueChanged(QString)));
    connect(m_settings, SIGNAL(valueChanged(QString)), this, SLOT(onValueChanged(QString)));

    m_ignored_properties << "objectName" << "group";
}

void AppSettings::classBegin()
{
    int slotIndex = metaObject()->indexOfSlot("onPropertyChanged()");

    for (int k = 0; k < metaObject()->propertyCount(); k++) {
        const QMetaProperty prop = metaObject()->property(k);
        if (prop.hasNotifySignal() && !m_ignored_properties.contains(prop.name())) {
            // In onPropertyChanged() slot we use senderSignalIndex()
            // to identify property that was changed.
            m_properties.insert(prop.notifySignalIndex(), prop.name());
            // This will be needed in componentComplete() to know which properties
            // were not set from QML and should be set from QSettings.
            m_unset_properties.insert(prop.name());
            // Get the notification when property is set from QML side
            connect(this, prop.notifySignal(), this, metaObject()->method(slotIndex));
        }
    }
}

void AppSettings::componentComplete()
{
    // Store to settings the values that were
    // set from QML on component creation.
    foreach (const QString prop, m_properties.values()) {
        if (m_unset_properties.contains(prop))
            continue;

        const QVariant val = property(prop.toUtf8());
        if (val.isValid())
            setValue(prop, val);
        else
            remove(prop);
    }
    // Set properties that were not set from
    // QML to values from the settings.
    foreach (const QString prop, m_unset_properties.values()) {
        const QVariant val = value(prop);
        if (val.isValid())
            setProperty(prop.toUtf8(), val);
    }
    m_componentComplete = true;
}

QString AppSettings::group() const
{
    return m_keyPrefix.left(m_keyPrefix.length() - 1);
}

void AppSettings::setGroup(const QString &group)
{
    // Don't allow group to be set from
    // QML, except at construction.
    if (m_componentComplete || group == this->group())
        return;

    m_groupStack.clear();
    m_keyPrefix.clear();

    const QStringList groups = group.split("/");
    foreach (const QString &str, groups) {
        // Case when group path contains two
        // (or more) consecutive slashes.
        if (str.isEmpty())
            continue;

        m_groupStack.push(str);
        m_keyPrefix.append(str).append("/");
    }

    emit groupChanged();
}

bool AppSettings::capitalizeFirstLetter() const
{
    return m_capitalizeFirst;
}

void AppSettings::setCapitalizeFirstLetter(bool enable)
{
    if (enable == m_capitalizeFirst)
        return;

    m_capitalizeFirst = enable;
    emit capitalizeFirstLetterChanged();
}

void AppSettings::beginGroup(const QString &prefix)
{
    if (prefix.isEmpty())
        return;

    m_groupStack.push(prefix);
    m_keyPrefix.append(prefix).append("/");

    emit groupChanged();
}

void AppSettings::endGroup()
{
    const QString prefix = m_groupStack.pop();
    m_keyPrefix.chop(prefix.length() + 1);
    emit groupChanged();
}

bool AppSettings::contains(const QString &key) const
{
    return m_settings->contains(m_keyPrefix + capitalize(key));
}

void AppSettings::remove(const QString &key)
{
    m_settings->remove(m_keyPrefix + capitalize(key));
}

void AppSettings::setValue(const QString &key, const QVariant &value)
{
    m_settings->setValue(m_keyPrefix + capitalize(key), value);
}

QVariant AppSettings::value(const QString &key, const QVariant &defaultValue) const
{
    return m_settings->value(m_keyPrefix + capitalize(key), defaultValue);
}

void AppSettings::onValueChanged(const QString &key)
{
    if (!key.startsWith(m_keyPrefix))
        return;

    const QByteArray prop = decapitalize(key.mid(m_keyPrefix.length())).toUtf8();
    if (m_properties.values().contains(prop))
        setProperty(prop, value(prop));
}

void AppSettings::onPropertyChanged()
{
    foreach (const QString prop, m_properties.values(senderSignalIndex())) {
        m_unset_properties.remove(prop);

        // Group may not be set yet, wait until componentComplete()
        // is called and set the values from there.
        if (!m_componentComplete)
            continue;

        const QVariant val = property(prop.toUtf8());
        if (val.isValid())
            setValue(prop, val);
        else
            remove(prop);
    }
}

inline QString AppSettings::capitalize(const QString &str) const
{
    if (!m_capitalizeFirst)
        return str;

    QString result = str;
    result[0] = result.at(0).toUpper();
    return result;
}

inline QString AppSettings::decapitalize(const QString &str) const
{
    if (!m_capitalizeFirst)
        return str;

    QString result = str;
    result[0] = result.at(0).toLower();
    return result;
}
