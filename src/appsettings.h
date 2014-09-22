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

#ifndef APPSETTINGS_H
#define APPSETTINGS_H

#include <QObject>
#include <QVariant>

class SingleSettings;
class AppSettings: public QObject
{
    Q_OBJECT

public:
    AppSettings(QObject *parent = 0);

    void beginGroup(const QString &prefix);
    QString group() const;
    void endGroup();

    bool contains(const QString &key) const;
    void remove(const QString &key);
    void setValue(const QString &key, const QVariant &value);
    QVariant value(const QString &key, const QVariant &defaultValue = QVariant()) const;

signals:
    void valueChanged(const QString &key);

private slots:
    void onValueChanged(const QString &key);

private:
    SingleSettings *m_settings;
    QString m_group;
};

#endif // APPSETTINGS_H
