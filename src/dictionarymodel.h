/*
 *  The Advanced Online Translator
 *  Copyright (C) 2013  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
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

#ifndef DICTIONARYMODEL_H
#define DICTIONARYMODEL_H

#include "reversetranslationsmodel.h"

#include <QAbstractListModel>
#include <QString>
#include <QStringList>
#include <QSharedPointer>
#include <QCoreApplication>

class DictionaryPos
{
    Q_DECLARE_TR_FUNCTIONS(DictionaryPos)

public:
    DictionaryPos(const QString &pos, const QStringList &translations = QStringList());

    QString pos() const;
    QString translations(const QString separator) const;
    QStringList &translations();
    ReverseTranslationsModel *reverseTranslations() const;

private:
    QString m_pos;
    QStringList m_translations;
    ReverseTranslationsModel *m_reverse;
    QSharedPointer<ReverseTranslationsModel> ptr;
};

class DictionaryModel: public QAbstractListModel
{
    Q_OBJECT

public:
    enum DictionaryRoles {
        PosRole = Qt::UserRole + 1,
        TranslationsRole,
        ReverseTranslationsRole
    };

    explicit DictionaryModel(QObject *parent = 0);

    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    void append(const DictionaryPos &pos);
    void clear();

private:
    QList<DictionaryPos> m_dict;
};

Q_DECLARE_METATYPE(DictionaryModel *)

#endif // DICTIONARYMODEL_H
