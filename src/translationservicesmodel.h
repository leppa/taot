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

#ifndef TRANSLATIONSERVICESMODEL_H
#define TRANSLATIONSERVICESMODEL_H

#include <QStringListModel>

class TranslationServiceItem: public QObject
{
    Q_OBJECT
    Q_PROPERTY(int index READ index CONSTANT)
    Q_PROPERTY(QString name READ name CONSTANT)

public:
    TranslationServiceItem(int index, const QString &name, QObject *parent = 0);

    int index() const;
    QString name() const;

private:
    int m_id;
    QString m_name;
};

// A wrapper around QStringListModel to make it more QML friendly.
class TranslationServicesModel: public QStringListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count CONSTANT)

public:
    explicit TranslationServicesModel(const QStringList &strings, QObject *parent = 0);
    QHash<int, QByteArray> roleNames() const;
    int count() const;

public slots:
    QString get(int index) const;
};

Q_DECLARE_METATYPE(TranslationServiceItem *)
Q_DECLARE_METATYPE(TranslationServicesModel *)

#endif // TRANSLATIONSERVICESMODEL_H
