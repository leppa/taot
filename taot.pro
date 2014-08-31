######################################################################
#
#  TAO Translator
#  Copyright (C) 2013-2014  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
#
#  $Id: $Format:%h %ai %an$ $
#
#  This file is part of TAO Translator.
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License along
#  with this program.  If not, see <http://www.gnu.org/licenses/>.
#
######################################################################

TEMPLATE = app
lessThan(QT_MAJOR_VERSION, 5) {
    QT += declarative network script
} else {
    QT += quick network
}

blackberry:CONFIG += cascades

QMAKE_TARGET_COMPANY = Oleksii Serdiuk
QMAKE_TARGET_PRODUCT = TAO Translator
QMAKE_TARGET_DESCRIPTION = Online translator with some advanced features
QMAKE_TARGET_COPYRIGHT = Copyright © 2013-2014 Oleksii Serdiuk <contacts[at]oleksii[dot]name>

lessThan(QT_MAJOR_VERSION, 5):!blackberry {
    include(qmlapplicationviewer/qmlapplicationviewer.pri)
}

sailfish {
    DEFINES += Q_OS_SAILFISH
}

HEADERS += \
    src/translationinterface.h \
    src/languagelistmodel.h \
    src/translationservice.h \
    src/translationservicesmodel.h \
    src/updater.h \
    src/services/apikeys.h \
    src/services/jsontranslationservice.h \
    src/services/googletranslate.h \
    src/services/microsofttranslator.h \
    src/services/yandextranslationservice.h \
    src/services/yandextranslate.h \
    src/services/yandexdictionaries.h

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += \
    src/main.cpp \
    src/translationinterface.cpp \
    src/languagelistmodel.cpp \
    src/translationservice.cpp \
    src/translationservicesmodel.cpp \
    src/updater.cpp \
    src/services/jsontranslationservice.cpp \
    src/services/googletranslate.cpp \
    src/services/microsofttranslator.cpp \
    src/services/yandextranslationservice.cpp \
    src/services/yandextranslate.cpp \
    src/services/yandexdictionaries.cpp

blackberry {
    HEADERS += \
        src/bb10/dictionarymodel.h \
        src/bb10/reversetranslationsmodel.h \
        src/bb10/languagechangelistener.h \
        src/bb10/clipboard.h \
        src/bb10/repeater.h

    SOURCES += \
        src/bb10/dictionarymodel.cpp \
        src/bb10/reversetranslationsmodel.cpp \
        src/bb10/languagechangelistener.cpp \
        src/bb10/clipboard.cpp \
        src/bb10/repeater.cpp

    LIBS += -lbbsystem
} else {
    HEADERS += \
        src/dictionarymodel.h \
        src/reversetranslationsmodel.h

    SOURCES += \
        src/dictionarymodel.cpp \
        src/reversetranslationsmodel.cpp
}

symbian {
    HEADERS += \
        src/symbian/symbianapplication.h

    SOURCES += \
        src/symbian/symbianapplication.cpp
}

INCLUDEPATH += \
    src

RESOURCES += \
    data/data.qrc \
    l10n/l10n.qrc

TRANSLATIONS += \
    l10n/taot_da.ts \
    l10n/taot_de.ts \
    l10n/taot_en.ts \
    l10n/taot_fi.ts \
    l10n/taot_it.ts \
    l10n/taot_nl_NL.ts \
    l10n/taot_ru.ts \
    l10n/taot_tr.ts \
    l10n/taot_uk.ts \
    l10n/taot_zh_CN.ts

translate_hack {
    SOURCES += \
        qml/bb10/*.qml \
        qml/harmattan/*.qml \
        qml/sailfish/*.qml \
        qml/symbian/*.qml
}

OTHER_FILES += \
    bar-descriptor.xml \
    data/*.pem \
    data/langs/*.json \
    qml/about.js \
    qml/bb10/*.qml \
    qml/harmattan/*.js \
    qml/harmattan/*.qml \
    qml/harmattan/icons/* \
    qml/sailfish/*.js \
    qml/sailfish/*.qml \
    qml/sailfish/icons/* \
    qml/symbian/*.qml \
    qml/symbian/icons/* \
    qtc_packaging/debian_harmattan/*

# Extracting version from bar-descriptor.xml file.
BARFILE = $$cat(bar-descriptor.xml)
VERSION = $$find(BARFILE, <versionNumber>.*</versionNumber>)
VERSION = $$replace(VERSION, "<versionNumber>", "")
VERSION = $$replace(VERSION, "</versionNumber>", "")
symbian {
    DEFINES += VERSION=$$VERSION
} else {
    DEFINES += VERSION=\"$$VERSION\"
}

symbian {
    CONFIG += qt-components

    DEPLOYMENT.display_name = TAO Translator
    ICON = taot.svg

    TARGET.UID3 = 0xA001635A
    TARGET.CAPABILITY += NetworkServices ReadUserData
    TARGET.EPOCHEAPSIZE = 0x20000 0x2000000

    ui.sources = qml/about.js qml/symbian/* qml/symbian/icons
    ui.path = qml
    DEPLOYMENT += ui

    vendor = \
        "%{\"$$QMAKE_TARGET_COMPANY\"}" \
        ":\"$$QMAKE_TARGET_COMPANY\""
    default_deployment.pkg_prerules += vendor

    # Next lines replace automatic addition of Qt Components dependency to .sis file
    # with the manual one. For some reason, minimal required version is set to 1.0
    # instead of 1.1 so we want to replace it with the correct dependency.
    CONFIG += qt-components_build
    qt-components = \
        "; Default dependency to Qt Quick Components for Symbian library" \
        "(0x200346DE), 1, 1, 0, {\"Qt Quick components for Symbian\"}"
    default_deployment.pkg_prerules += qt-components

    !isEmpty(QMLJSDEBUGGER_PATH) {
        include($$QMLJSDEBUGGER_PATH/qmljsdebugger-lib.pri)
    } else {
        DEFINES -= QMLJSDEBUGGER
    }
}

contains(MEEGO_EDITION,harmattan) {
    CONFIG += qt-components qdeclarative-boostable
    DEFINES += HARMATTAN_BOOSTER

    target.path = /opt/$${TARGET}/bin
    ui.files = qml/about.js qml/harmattan/*
    ui.path = /opt/$${TARGET}/qml
    icon.files = $${TARGET}80.png
    icon.path = /usr/share/icons/hicolor/80x80/apps
    desktopfile.files = qtc_packaging/$${TARGET}_harmattan.desktop
    desktopfile.path = /usr/share/applications

    INSTALLS += target ui icon desktopfile
}

# Sailfish
sailfish {
    TARGET = harbour-taot

    target.path = /usr/bin
    ui.files = qml/about.js qml/sailfish/*
    ui.path = /usr/share/$${TARGET}/qml
    icon.files = $${TARGET}.png
    icon.path = /usr/share/icons/hicolor/86x86/apps
    desktopfile.files = rpm/$${TARGET}.desktop
    desktopfile.path = /usr/share/applications

    INSTALLS += target ui icon desktopfile

    CONFIG += link_pkgconfig
    PKGCONFIG += sailfishapp
    INCLUDEPATH += /usr/include/sailfishapp

    OTHER_FILES += $$files(rpm/*)
}

# We need to generate translations before building.
# Either way, resource files won't compile.
translations.name = Translations
translations.input = TRANSLATIONS
translations.output = $$_PRO_FILE_PWD_/l10n/${QMAKE_FILE_BASE}.qm
freebsd-* {
    translations.commands = $$[QT_INSTALL_BINS]/lrelease-qt$${QT_MAJOR_VERSION} ${QMAKE_FILE_IN}
} else {
    translations.commands = $$[QT_INSTALL_BINS]/lrelease ${QMAKE_FILE_IN}
}
translations.CONFIG = no_link
QMAKE_EXTRA_COMPILERS += translations
PRE_TARGETDEPS += compiler_translations_make_all
