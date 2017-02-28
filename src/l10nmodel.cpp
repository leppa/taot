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

#include "l10nmodel.h"

#include <QDir>
#include <QStringList>
#include <QCoreApplication>
#include <QSettings>

#include <QDebug>

inline QString capitalize(QString str)
{
    if (str.isEmpty())
        return str;

    str.toLower();
    str[0] = str.at(0).toUpper();
    return str;
}

L10nModel::L10nModel(QObject *parent)
    : QAbstractListModel(parent)
#ifdef Q_OS_SAILFISH
    , m_settings(new QSettings("harbour-taot", "taot"))
#else
    , m_settings(new QSettings(QCoreApplication::organizationName(), "taot"))
#endif

{
#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    setRoleNames(roleNames());
#endif

    m_translations = new QStringList();
    *m_translations << "";

    QDir l10n(":/l10n");
    const QStringList translations = l10n.entryList(QStringList() << "taot_*.qm",
                                                    QDir::Files | QDir::Readable);
    foreach (QString translation, translations) {
        // Remove "taot_" at the beginning and ".qm" at the end
        translation.remove(0, 5).chop(3);
        *m_translations << translation;
    }
}

QHash<int, QByteArray> L10nModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(Qt::DisplayRole, "name");
    roles.insert(LanguageRole, "language");
    return roles;
}

int L10nModel::count() const
{
    return m_translations->count();
}

int L10nModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return count();
}

QVariant L10nModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_translations->count())
        return QVariant();

    switch (role) {
    case Qt::DisplayRole:
        if (index.row() == 0) {
#if QT_VERSION >= QT_VERSION_CHECK(4, 8, 0)
            //: The default language in the system (%1 will be replaced with language name)
            return tr("System default (%1)").arg(capitalize(QLocale().nativeLanguageName()));
#else
            return tr("System default (%1)").arg(capitalize(QLocale::languageToString(
                                                                QLocale().language())));
#endif
        } else {
#if QT_VERSION >= QT_VERSION_CHECK(4, 8, 0)
            return capitalize(QLocale(m_translations->at(index.row())).nativeLanguageName());
#else
            return capitalize(QLocale::languageToString(
                                  QLocale(m_translations->at(index.row())).language()));
#endif
        }
    case LanguageRole:
        return m_translations->at(index.row());
    default:
        return QVariant();
    }
}

int L10nModel::currentIndex() const
{
    return m_translations->indexOf(currentLanguage());
}

QString L10nModel::currentLanguage() const
{
    if (m_settings->contains("UILanguage")) {
        const QString lang = m_settings->value("UILanguage").toString();
        if (!lang.isEmpty())
            return lang;
    }

    return QString();
}

void L10nModel::setCurrentLanguage(const QString &language)
{
    if (m_settings->value("UILanguage").toString() == language)
        return;

    if (language.isEmpty())
        m_settings->remove("UILanguage");
    else
        m_settings->setValue("UILanguage", language);

    emit currentLanguageChanged();
}

QVariantMap L10nModel::get(int index) const
{
    QModelIndex ind = createIndex(index, 0);
    QVariantMap map;
    map.insert("name", data(ind, Qt::DisplayRole));
    map.insert("language", data(ind, LanguageRole));
    return map;
}

L10nModel::~L10nModel()
{
    delete m_settings;
    delete m_translations;
}
