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

#include "bb10/reversetranslationsmodel.h"

void ReverseTranslations::append(const QString &term,
                                 const QStringList &synonyms,
                                 const QStringList &translations)
{
    QVariantMap map;
    map.insert("term", term);
    map.insert("synonyms", synonyms.join(tr(", ")));
    map.insert("translations", translations.join(tr(", ")));

    QList<QVariantMap>::append(map);
}

ReverseTranslationsModel::ReverseTranslationsModel(QList<QVariantMap> *list, QObject *parent)
    : bb::cascades::QMapListDataModel()
{
    setParent(parent);
    append(*list);
}
