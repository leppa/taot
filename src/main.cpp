/*
 *  The Advanced Online Translator.
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

#include "qmlapplicationviewer.h"
#include "translationinterface.h"
#include "dictionarymodel.h"
#include "reversetranslationsmodel.h"

#include <QApplication>
#include <QtDeclarative>

int main(int argc, char *argv[])
{
    QApplication::setApplicationName("The Advanced Online Translator");
    QApplication::setApplicationVersion("0.1.0");
    QApplication::setOrganizationName("Oleksii Serdiuk");
    QApplication::setOrganizationDomain("oleksii.name");

    QScopedPointer<QApplication> app(createApplication(argc, argv));

    qmlRegisterType<TranslationInterface>("taot", 1, 0, "Translator");
    qmlRegisterType<DictionaryModel>();
    qmlRegisterType<ReverseTranslationsModel>();

    QmlApplicationViewer viewer;
    viewer.addImportPath(QLatin1String("modules")); // ADDIMPORTPATH
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto); // ORIENTATION
    viewer.setMainQmlFile(QLatin1String("qml/main.qml")); // MAINQML
    viewer.showExpanded();

    return app->exec();
}
