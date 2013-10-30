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
QML_IMPORT_PATH = 3rdparty/bb10-qt-components/imports

HEADERS += \
    src/translationinterface.h \
    src/dictionarymodel.h \
    src/reversetranslationsmodel.h

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += \
    src/main.cpp \
    src/translationinterface.cpp \
    src/dictionarymodel.cpp \
    src/reversetranslationsmodel.cpp

OTHER_FILES += \
    bar-descriptor.xml \
    qml/langs.xml \
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

    ui.sources = qml/langs.xml qml/symbian/* qml/symbian/icons
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
