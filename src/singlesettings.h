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

#ifndef SINGLESETTINGS_H
#define SINGLESETTINGS_H

#include <QObject>
#include <QAtomicPointer>
#include <QMutex>
#include <QVariant>

class QSettings;
class SingleSettings: public QObject
{
    Q_OBJECT

public:
    static SingleSettings *getInstance();

    bool contains(const QString &key) const;
    void remove(const QString &key);
    void setValue(const QString &key, const QVariant &value);
    QVariant value(const QString &key, const QVariant &defaultValue = QVariant()) const;

signals:
    void valueChanged(const QString &key);

private:
    explicit SingleSettings(QObject *parent = 0);
    Q_DISABLE_COPY(SingleSettings)

    QSettings *m_settings;

    static QAtomicPointer<SingleSettings> m_instance;
    static QMutex m_mutex;
};

#endif // SINGLESETTINGS_H
