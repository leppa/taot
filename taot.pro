######################################################################
#
#  The Advanced Online Translator.
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
QT += network script

# Please do not modify the following line.
include(qmlapplicationviewer/qmlapplicationviewer.pri)

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

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
    qml/*
