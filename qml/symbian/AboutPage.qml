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

import QtQuick 1.1
import com.nokia.symbian 1.1
import "about.js" as About

Page {
    id: root

    property bool platformInverted: false

    Header {
        id: header
        text: "TAO Translator"
    }

    Flickable {
        id: scrollArea

        contentHeight: column.height + 2 * platformStyle.paddingMedium
        anchors {
            top: header.bottom
            left: parent.left
            bottom: parent.bottom
            right: parent.right
        }

        Column {
            id: column

            spacing: platformStyle.paddingMedium
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: platformStyle.paddingMedium
            }

            Label {
                width: parent.width
                text: qsTr("Version: <b>%1</b>").arg(translator.version)
                platformInverted: root.platformInverted
                font.pixelSize: platformStyle.fontSizeLarge
            }

            Label {
                text: About.aboutText
                wrapMode: Text.WordWrap
                width: parent.width
                platformInverted: root.platformInverted

                onLinkActivated: {
                    Qt.openUrlExternally(link);
                }
            }
        }
    }

    ScrollDecorator {
        flickableItem: scrollArea
    }

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back"
            platformInverted: root.platformInverted
            onClicked: pageStack.pop();
        }
    }
}
