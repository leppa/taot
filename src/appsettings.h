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
#include <QStack>
#include <QSet>
#include <QVariant>
#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
#   include <QDeclarativeParserStatus>
#   define QQmlParserStatus QDeclarativeParserStatus
#else
#   include <QQmlParserStatus>
#endif

class SingleSettings;
class AppSettings: public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_PROPERTY(QString group READ group WRITE setGroup NOTIFY groupChanged)
    Q_PROPERTY(bool capitalizeFirstLetter READ capitalizeFirstLetter
                                          WRITE setCapitalizeFirstLetter
                                          NOTIFY capitalizeFirstLetterChanged)

public:
    AppSettings(QObject *parent = 0);

    void classBegin();
    void componentComplete();

    QString group() const;
    void setGroup(const QString &group);

    bool capitalizeFirstLetter() const;
    void setCapitalizeFirstLetter(bool enable);

    void beginGroup(const QString &prefix);
    void endGroup();

    bool contains(const QString &key) const;
    void remove(const QString &key);
    void setValue(const QString &key, const QVariant &value);
    QVariant value(const QString &key, const QVariant &defaultValue = QVariant()) const;

signals:
    void groupChanged();
    void capitalizeFirstLetterChanged();
    void valueChanged(const QString &key);

private slots:
    void onValueChanged(const QString &key);
    void onPropertyChanged();

private:
    bool m_componentComplete;
    bool m_capitalizeFirst;

    SingleSettings *m_settings;

    QStack<QString> m_groupStack;
    QString m_keyPrefix;

    QSet<QString> m_ignored_properties;
    QSet<QString> m_unset_properties;
    QMultiHash<int, QString> m_properties;

    QString capitalize(const QString &str) const;
    QString decapitalize(const QString &str) const;
};

#endif // APPSETTINGS_H
