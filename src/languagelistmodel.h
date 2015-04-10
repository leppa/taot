/*
 *  TAO Translator
 *  Copyright (C) 2013-2015  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
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

#ifndef LANGUAGELISTMODEL_H
#define LANGUAGELISTMODEL_H

#include "translationservice.h"

#include <QAbstractListModel>

class LanguageItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString displayName READ displayName CONSTANT)
    Q_PROPERTY(QVariant info READ info CONSTANT)
    Q_PROPERTY(int index READ index NOTIFY indexChanged)

public:
    LanguageItem(const Language &language, int index, QObject *parent = 0);

    Language language() const;
    QString displayName() const;
    QVariant info() const;
    int index() const;
    void setIndex(int index);

signals:
    void indexChanged();

private:
    const Language m_language;
    int m_index;
};

class LanguageListModel: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum LanguageListRoles {
        InfoRole = Qt::UserRole + 1
    };

    explicit LanguageListModel(QObject *parent = 0);

    QHash<int, QByteArray> roleNames() const;

    int count() const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    void setLanguageList(const LanguageList &list);
    Language get(int index) const;

    int indexOf(const Language language) const;

public slots:
    int indexOf(LanguageItem *language) const;
    QString displayNameOf(int index) const;

signals:
    int countChanged();

private:
    LanguageList m_languages;
};

Q_DECLARE_METATYPE(LanguageItem *)
Q_DECLARE_METATYPE(LanguageListModel *)

#endif // LANGUAGELISTMODEL_H
