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

#include "jsontranslationservice.h"

JsonTranslationService::JsonTranslationService(QObject *parent)
    : TranslationService(parent)
{}

QScriptValue JsonTranslationService::parseJson(const QString &json)
{
    if (!engine.canEvaluate(json))
        return QScriptValue(false);

    if (!engine.canEvaluate(json)) {
        m_error = tr("Couldn't parse response from the server because of an error: \"%1\"")
                  .arg(tr("Can't evaluate JSON data"));
        return QScriptValue();
    }

    QScriptValue data = engine.evaluate(json);
    if (engine.hasUncaughtException()) {
        m_error = tr("Couldn't parse response from the server because of an error: \"%1\"")
                  .arg(engine.uncaughtException().toString());
        return QScriptValue();
    }

    return data;
}
