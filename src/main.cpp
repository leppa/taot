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

#include <QtGlobal>

#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
#   include "qmlapplicationviewer.h"
#endif
#include "translationinterface.h"
#include "translationservice.h"
#include "translationservicesmodel.h"
#include "languagelistmodel.h"
#include "dictionarymodel.h"
#include "reversetranslationsmodel.h"

#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
#   include <QApplication>
#else
#   include <QGuiApplication>
#endif
#include <QTextCodec>
#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
#   include <QtDeclarative>
#else
#   include <QtQuick>
#endif

#include <qplatformdefs.h>

#ifdef Q_OS_BLACKBERRY
#   include <QGLWidget>
#elif defined(Q_OS_SAILFISH)
#   include <sailfishapp.h>
#endif

#define QUOTE_X(x) #x
#define QUOTE(x) QUOTE_X(x)
#define VERSION_STR QUOTE(VERSION)

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QTextCodec::setCodecForLocale(QTextCodec::codecForName("utf8"));
#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    QTextCodec::setCodecForCStrings(QTextCodec::codecForName("utf8"));
    QTextCodec::setCodecForTr(QTextCodec::codecForName("utf8"));
#endif

    QCoreApplication::setApplicationName("The Advanced Online Translator");
    QCoreApplication::setApplicationVersion(VERSION_STR);
    QCoreApplication::setOrganizationName("Oleksii Serdiuk");
    QCoreApplication::setOrganizationDomain("oleksii.name");

#ifdef Q_OS_BLACKBERRY
    // This is needed for clicks to work more reliably indside Flickable.
    QApplication::setStartDragDistance(42);
#endif

#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    QScopedPointer<QApplication> app(createApplication(argc, argv));
#elif defined(Q_OS_SAILFISH)
    QGuiApplication *app = SailfishApp::application(argc, argv);
#else
    QScopedPointer<QGuiApplication> app(new QGuiApplication(argc, argv));
#endif

    const QString lc = QLocale().name();
    // Load Qt's translation
    QTranslator qtTr;
    if (qtTr.load("qt_" + lc, QLibraryInfo::location(QLibraryInfo::TranslationsPath)))
        app->installTranslator(&qtTr);
    // Load TAOT's translation
    QTranslator tr;
    if (tr.load("taot_" + lc, ":/l10n"))
        app->installTranslator(&tr);

#ifdef Q_OS_SAILFISH
    qmlRegisterType<TranslationInterface>("harbour.taot", 1, 0, "Translator");
#else
    qmlRegisterType<TranslationInterface>("taot", 1, 0, "Translator");
#endif
    qmlRegisterType<TranslationServiceItem>();
    qmlRegisterType<TranslationServicesModel>();
    qmlRegisterType<LanguageItem>();
    qmlRegisterType<LanguageListModel>();
    qmlRegisterType<DictionaryModel>();
    qmlRegisterType<ReverseTranslationsModel>();

#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    QmlApplicationViewer viewer;
#elif defined(Q_OS_SAILFISH)
    QQuickView *viewer = SailfishApp::createView();
#else
    QQuickView viewer;
#endif

#ifdef Q_OS_BLACKBERRY
    QGLWidget *gl = new QGLWidget();
    viewer.setViewport(gl);
    viewer.setViewportUpdateMode(QGraphicsView::FullViewportUpdate);
#elif QT_VERSION < QT_VERSION_CHECK(5,0,0)
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
#endif

    // TODO: Remove this after 01.01.2014.
#if defined(Q_OS_SYMBIAN) || defined(MEEGO_EDITION_HARMATTAN)
    viewer.rootContext()->setContextProperty("showNokiaStoreNotice", "true");
#elif !defined(Q_OS_SAILFISH)
    viewer.rootContext()->setContextProperty("showNokiaStoreNotice", "false");
#endif

#ifdef MEEGO_EDITION_HARMATTAN
    QDir dir(app->applicationDirPath());
    dir.cdUp();
    viewer.setMainQmlFile(dir.filePath(QLatin1String("qml/main.qml")));
#elif QT_VERSION < QT_VERSION_CHECK(5,0,0)
    viewer.setMainQmlFile(QLatin1String("qml/main.qml"));
#elif defined(Q_OS_SAILFISH)
    QObject::connect(viewer->engine(), SIGNAL(quit()), app, SLOT(quit()));
    viewer->setSource(SailfishApp::pathTo("qml/main.qml"));
#else
    QObject::connect(viewer.engine(), SIGNAL(quit()), app.data(), SLOT(quit()));
    viewer.setSource(QUrl(QLatin1String("qml/main.qml")));
#endif
#ifdef Q_OS_BLACKBERRY
    viewer.rootObject()->setProperty("showStatusBar", false);
    viewer.showFullScreen();
#elif QT_VERSION < QT_VERSION_CHECK(5,0,0)
    viewer.showExpanded();
#elif defined(Q_OS_SAILFISH)
    viewer->show();
#else
    viewer.show();
#endif

    return app->exec();
}
