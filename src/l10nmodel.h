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

#ifndef L10NMODEL_H
#define L10NMODEL_H

#include <QAbstractListModel>
#include <QLocale>

class QStringList;
class QSettings;
class L10nModel: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count CONSTANT)
    Q_PROPERTY(int currentIndex READ currentIndex NOTIFY currentLanguageChanged)
    Q_PROPERTY(QString currentLanguage READ currentLanguage
                                       WRITE setCurrentLanguage
                                       NOTIFY currentLanguageChanged)

public:
    enum L10nRoles {
        LanguageRole = Qt::UserRole + 1
    };

    explicit L10nModel(QObject *parent = 0);

    QHash<int, QByteArray> roleNames() const;

    int count() const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    int currentIndex() const;

    QString currentLanguage() const;
    void setCurrentLanguage(const QString &language);

    Q_INVOKABLE QVariantMap get(int index) const;

    ~L10nModel();

signals:
    void currentLanguageChanged();

private:
    QStringList *m_translations;
    QSettings *m_settings;
};

#endif // L10NMODEL_H
