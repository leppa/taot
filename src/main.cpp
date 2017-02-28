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

#include <QtGlobal>

#if !defined(Q_OS_BLACKBERRY) && QT_VERSION < QT_VERSION_CHECK(5,0,0)
#   include "qmlapplicationviewer.h"
#endif
#include "translationinterface.h"
#include "translationservice.h"
#include "translationservicesmodel.h"
#include "languagelistmodel.h"
#include "l10nmodel.h"
#ifdef Q_OS_BLACKBERRY
#   include "bb10/dictionarymodel.h"
#   include "bb10/reversetranslationsmodel.h"
#   include "bb10/languagechangelistener.h"
#   include "bb10/clipboard.h"
#   include "bb10/repeater.h"
#   include "bb10/donationmanager.h"
#else
#   include "dictionarymodel.h"
#   include "reversetranslationsmodel.h"
#   include "clipboard.h"
#endif
#include "updater.h"

#ifdef Q_OS_BLACKBERRY
#   include <bb/cascades/Application>
#   include <bb/cascades/QmlDocument>
#   include <bb/cascades/AbstractPane>
#   include <bb/cascades/Container>
#   include <bb/cascades/SceneCover>
#   include <bb/platform/PlatformInfo>
#   include <bb/system/SystemToast>
using namespace bb::cascades;
#elif defined(Q_OS_SYMBIAN)
#   include "symbian/symbianapplication.h"
#   include <QtDeclarative>
#elif QT_VERSION < QT_VERSION_CHECK(5,0,0)
#   include <QApplication>
#   include <QtDeclarative>
#else
#   include <QGuiApplication>
#   include <QtQuick>
#endif
#include <QTextCodec>
#include <QSettings>

#include <qplatformdefs.h>

#ifdef Q_OS_SAILFISH
#   include <sailfishapp.h>
#endif

#ifdef Q_OS_BLACKBERRY
void stdoutMessageOutput(QtMsgType, const char *msg)
{
    fprintf(stdout, "%s\n", QString::fromUtf8(msg).toLocal8Bit().constData());
    fflush(stdout);
}
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

#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    QCoreApplication::setApplicationName("TAO Translator");
#else
    QGuiApplication::setApplicationDisplayName("TAO Translator");
    QCoreApplication::setApplicationName("taot");
#endif
#if BUILD > 1
    QCoreApplication::setApplicationVersion(QString("%1 (build %2)").arg(VERSION_STR).arg(BUILD));
#else
    QCoreApplication::setApplicationVersion(VERSION_STR);
#endif
    QCoreApplication::setOrganizationName("Oleksii Serdiuk");
    QCoreApplication::setOrganizationDomain("oleksii.name");

#ifdef Q_OS_BLACKBERRY
    qInstallMsgHandler(stdoutMessageOutput);

    QSettings *sets = new QSettings(QCoreApplication::organizationName(), "taot");
    if (sets->contains("InvertedTheme"))
        qputenv("CASCADES_THEME", sets->value("InvertedTheme").toBool() ? "dark" : "bright");
    delete sets;

    QScopedPointer<Application> app(new Application(argc, argv));
#elif defined(Q_OS_SAILFISH)
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
#elif defined(Q_OS_SYMBIAN)
    QScopedPointer<QApplication> app(new SymbianApplication(argc, argv));
#elif QT_VERSION < QT_VERSION_CHECK(5,0,0)
    QScopedPointer<QApplication> app(createApplication(argc, argv));
#else
    QScopedPointer<QGuiApplication> app(new QGuiApplication(argc, argv));
#endif

#if QT_VERSION < QT_VERSION_CHECK(4,8,0)
    // More and more sites are disabling SSLv3 due to vulnerabilities,
    // however Qt < 4.8 has only SSLv3 enabled by default.
    QSslConfiguration sslConfig = QSslConfiguration::defaultConfiguration();
    sslConfig.setProtocol(QSsl::TlsV1);
    QSslConfiguration::setDefaultConfiguration(sslConfig);
#endif

#ifdef Q_OS_BLACKBERRY
    LanguageChangeListener *listener = new LanguageChangeListener(app.data());
    Q_UNUSED(listener);
#else
# ifdef Q_OS_SAILFISH
    QSettings settings("harbour-taot", "taot");
# else
    QSettings settings(QCoreApplication::organizationName(), "taot");
# endif
    QString lc = QLocale().name();
    if (settings.contains("UILanguage")) {
        const QString lang = settings.value("UILanguage").toString();
        if (!lang.isEmpty())
            lc = lang;
    }

    // Load Qt's translation
    QTranslator qtTr;
    if (qtTr.load("qt_" + lc, QLibraryInfo::location(QLibraryInfo::TranslationsPath)))
        app->installTranslator(&qtTr);
    // Load TAOT's translation
    QTranslator tr;
    if (tr.load("taot_" + lc, ":/l10n"))
        app->installTranslator(&tr);
#endif

#ifdef Q_OS_SAILFISH
    qmlRegisterType<TranslationInterface>("harbour.taot", 1, 0, "Translator");
    qmlRegisterType<L10nModel>("harbour.taot", 1, 0, "L10nModel");
    qmlRegisterType<Updater>("harbour.taot", 1, 0, "Updater");
#else
    qmlRegisterType<TranslationInterface>("taot", 1, 0, "Translator");
    qmlRegisterType<L10nModel>("taot", 1, 0, "L10nModel");
    qmlRegisterType<Clipboard>("taot", 1, 0, "Clipboard");
    qmlRegisterType<Updater>("taot", 1, 0, "Updater");
#endif
    qmlRegisterType<SourceTranslatedTextPair>();
    qmlRegisterType<TranslationServiceItem>();
    qmlRegisterType<TranslationServicesModel>();
    qmlRegisterType<LanguageItem>();
    qmlRegisterType<LanguageListModel>();
    qmlRegisterType<DictionaryModel>();
    qmlRegisterType<ReverseTranslationsModel>();
    qmlRegisterType<Release>();

#ifdef Q_OS_BLACKBERRY
    qmlRegisterType<bb::system::SystemToast>("bb.system", 1, 0, "SystemToast");
    qmlRegisterType<Repeater>("taot", 1, 0, "Repeater");
    qmlRegisterType<DonationManager>("taot", 1, 0, "DonationManager");
#elif defined(Q_OS_SAILFISH)
    QScopedPointer<QQuickView> viewer(SailfishApp::createView());
#elif QT_VERSION < QT_VERSION_CHECK(5,0,0)
    QScopedPointer<QmlApplicationViewer> viewer(new QmlApplicationViewer());
    viewer->setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
#else
    QScopedPointer<QQuickView> viewer(new QQuickView());
#endif

#ifndef Q_OS_BLACKBERRY
# ifdef WITH_ANALYTICS
    viewer->engine()->rootContext()->setContextProperty("analytics_enabled", QVariant(true));
# else
    viewer->engine()->rootContext()->setContextProperty("analytics_enabled", QVariant(false));
# endif
#endif

#ifdef Q_OS_BLACKBERRY
    TranslationInterface *translator = new TranslationInterface(app.data());
    QmlDocument *qml = QmlDocument::create(QLatin1String("asset:///main.qml"))
            .property("translator", translator).parent(app.data());

    const QStringList v = bb::platform::PlatformInfo().osVersion().split(".");
    const int ver = v.count() >= 3 ? (v.at(0).toInt() << 16)
                                     + (v.at(1).toInt() << 8)
                                     + v.at(2).toInt()
                                   : 0;
    qml->documentContext()->setContextProperty("osVersion", ver);

# ifdef WITH_ANALYTICS
    qml->documentContext()->setContextProperty("analytics_enabled", QVariant(true));
# else
    qml->documentContext()->setContextProperty("analytics_enabled", QVariant(false));
# endif
#elif defined(MEEGO_EDITION_HARMATTAN)
    QDir dir(app->applicationDirPath());
    dir.cdUp();
    viewer->setMainQmlFile(dir.filePath(QLatin1String("qml/main.qml")));
#elif defined(Q_OS_SAILFISH)
    QObject::connect(viewer->engine(), SIGNAL(quit()), app.data(), SLOT(quit()));
    viewer->setSource(SailfishApp::pathTo("qml/main.qml"));
#elif QT_VERSION < QT_VERSION_CHECK(5,0,0)
    viewer->setMainQmlFile(QLatin1String("qml/main.qml"));
#else
    QObject::connect(viewer->engine(), SIGNAL(quit()), app.data(), SLOT(quit()));
    viewer->setSource(QUrl(QLatin1String("qml/main.qml")));
#endif

#ifdef Q_OS_BLACKBERRY
    app->setScene(qml->createRootObject<AbstractPane>());

    qml = QmlDocument::create("asset:///AppCover.qml").property("translator",
                                                                translator).parent(app.data());
    SceneCover *cover = new SceneCover(app.data());
    cover->setContent(qml->createRootObject<Container>());
    app->setCover(cover);
#elif QT_VERSION < QT_VERSION_CHECK(5,0,0)
    viewer->showExpanded();
#else
    viewer->show();
#endif

    return app->exec();
}

#ifdef DUMMY_CODE_THAT_WILL_NEVER_BE_BUILT
// This is meta information for translation files.
// Not used anywhere ATM. Just ignore it.
//: A list of translation authors
QT_TRANSLATE_NOOP3("--------", "AUTHORS");
//: Native language name (e.g., Deutsch for German)
QT_TRANSLATE_NOOP3("--------", "LANGUAGE_NAME");
#endif
