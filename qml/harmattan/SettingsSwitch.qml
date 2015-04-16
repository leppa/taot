/*
 *  TAO Translator
 *  Copyright (C) 2013-2015  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
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
import "constants.js" as UI

Item {
    id: root

    property alias title: titleLabel.text
    property alias description: descriptionLabel.text
    property alias checked: toggle.checked

    height: childrenRect.height
    anchors {
        left: parent.left
        right: parent.right
        leftMargin: UI.MARGIN_XLARGE
        rightMargin: UI.MARGIN_XLARGE
    }

    Column {
        id: labels

        anchors {
            left: parent.left
            right: toggle.left
            rightMargin: 8 /*UI.PADDING_LARGE*/
        }

        Label {
            id: titleLabel
            color: theme.inverted ? UI.LIST_TITLE_COLOR_INVERTED
                                  : UI.LIST_TITLE_COLOR
            font {
                weight: Font.Bold
                pixelSize: UI.LIST_TILE_SIZE
            }
            anchors {
                left: parent.left
                right: parent.right
            }
        }
        Label {
            id: descriptionLabel
            color: theme.inverted ? UI.LIST_SUBTITLE_COLOR_INVERTED
                                  : UI.LIST_SUBTITLE_COLOR
            font {
                weight: UI.LIST_SUBTILE_SIZE
                pixelSize: Font.Light
            }
            anchors {
                left: parent.left
                right: parent.right
            }
        }
    }
    Switch {
        id: toggle

        anchors {
            right: parent.right
            verticalCenter: labels.verticalCenter
        }
    }
}
