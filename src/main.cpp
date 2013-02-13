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

#include "qmlapplicationviewer.h"
#include "translationinterface.h"
#include "dictionarymodel.h"
#include "reversetranslationsmodel.h"

#include <QApplication>
#include <QTextCodec>
#include <QGLWidget>
#include <QtDeclarative>

#define QUOTE_X(x) #x
#define QUOTE(x) QUOTE_X(x)
#define VERSION_STR QUOTE(VERSION)

int main(int argc, char *argv[])
{
    QTextCodec::setCodecForLocale(QTextCodec::codecForName("utf8"));
    QTextCodec::setCodecForCStrings(QTextCodec::codecForName("utf8"));
    QTextCodec::setCodecForTr(QTextCodec::codecForName("utf8"));

    QApplication::setApplicationName("The Advanced Online Translator");
    QApplication::setApplicationVersion(VERSION_STR);
    QApplication::setOrganizationName("Oleksii Serdiuk");
    QApplication::setOrganizationDomain("oleksii.name");

    // This is needed for clicks to work more reliably indside Flickable.
    QApplication::setStartDragDistance(42);

    QScopedPointer<QApplication> app(createApplication(argc, argv));

    qmlRegisterType<TranslationInterface>("taot", 1, 0, "Translator");
    qmlRegisterType<DictionaryModel>();
    qmlRegisterType<ReverseTranslationsModel>();

    QGLWidget *gl = new QGLWidget();

    QmlApplicationViewer viewer;
    viewer.setViewport(gl);
    viewer.setViewportUpdateMode(QGraphicsView::FullViewportUpdate);
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationLockPortrait);
    viewer.setMainQmlFile(QLatin1String("qml/main.qml"));
    viewer.showFullScreen();

    return app->exec();
}
