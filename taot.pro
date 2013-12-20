######################################################################
#
#  The Advanced Online Translator
#  Copyright (C) 2013  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
#
#  $Id: $Format:%h %ai %an$ $
#
#  This file is part of The Advanced Online Translator.
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
QT += declarative network script
blackberry:QT += opengl

QMAKE_TARGET_COMPANY = Oleksii Serdiuk
QMAKE_TARGET_PRODUCT = The Advanced Online Translator
QMAKE_TARGET_DESCRIPTION = Online translator with some advanced features
QMAKE_TARGET_COPYRIGHT = Copyright © 2013 Oleksii Serdiuk <contacts[at]oleksii[dot]name>

# Please do not modify the following line.
include(qmlapplicationviewer/qmlapplicationviewer.pri)

# Additional import path used to resolve QML modules in Creator's code model
blackberry:QML_IMPORT_PATH = 3rdparty/bb10-qt-components/imports

HEADERS += \
    src/translationinterface.h \
    src/dictionarymodel.h \
    src/reversetranslationsmodel.h \
    src/languagelistmodel.h \
    src/translationservice.h \
    src/translationservicesmodel.h \
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
    src/dictionarymodel.cpp \
    src/reversetranslationsmodel.cpp \
    src/languagelistmodel.cpp \
    src/translationservice.cpp \
    src/translationservicesmodel.cpp \
    src/services/jsontranslationservice.cpp \
    src/services/googletranslate.cpp \
    src/services/microsofttranslator.cpp \
    src/services/yandextranslationservice.cpp \
    src/services/yandextranslate.cpp \
    src/services/yandexdictionaries.cpp

INCLUDEPATH += \
    src

RESOURCES += \
    data/data.qrc \
    l10n/l10n.qrc

TRANSLATIONS += \
    l10n/taot_ru.ts \
    l10n/taot_uk.ts

translate_hack {
    SOURCES += \
        qml/harmattan/*.qml \
        qml/symbian/*.qml
}

OTHER_FILES += \
    bar-descriptor.xml \
    data/*.pem \
    data/langs/*.json \
    qml/about.js \
    qml/harmattan/*.js \
    qml/harmattan/*.qml \
    qml/harmattan/icons/* \
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

    DEPLOYMENT.display_name = $$QMAKE_TARGET_PRODUCT
    ICON = taot.svg

    # OVI Publish - 0x2003AEFC, Self-signed - 0xA001635A
    ovi_publish {
        TARGET.UID3 = 0x2003AEFC
    } else {
        TARGET.UID3 = 0xA001635A
    }
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
