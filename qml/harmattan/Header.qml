/*
 *  TAO Translator
 *  Copyright (C) 2013-2016  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
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

import QtQuick 1.1
import com.nokia.meego 1.1

Rectangle {
    id: header

    property alias text: label.text

    z: 100
    height: appWindow.inPortrait ? UiConstants.HeaderDefaultHeightPortrait
                                 : UiConstants.HeaderDefaultHeightLandscape
    gradient: Gradient {
        GradientStop {
            position: 0.00
            color: theme.selectionColor
        }
        GradientStop {
            position: 1.0
            color: Qt.darker(theme.selectionColor)
        }
    }
    anchors {
        left: parent.left
        right: parent.right
    }

    Label {
        id: label

        color: "white"
        font: UiConstants.HeaderFont
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: UiConstants.DefaultMargin
        }
    }
}
