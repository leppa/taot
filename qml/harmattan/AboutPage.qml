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

import QtQuick 1.1
import com.nokia.meego 1.1
import "about.js" as About

Page {
    id: root

    property bool platformInverted: false

    Header {
        id: header
        text: "The Advanced Online Translator"
    }

    Flickable {
        id: scrollArea

        contentHeight: column.height + 2 * 8 /*UI.PADDING_LARGE*/
        anchors {
            top: header.bottom
            left: parent.left
            bottom: parent.bottom
            right: parent.right
        }

        Column {
            id: column

            spacing: 8 /*UI.PADDING_LARGE*/
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 8 /*UI.PADDING_LARGE*/
            }

            Label {
                width: parent.width
                text: qsTr("Version: <b>%1</b>").arg(translator.version)
                font: UiConstants.TitleFont
            }

            Label {
                text: About.aboutText
                wrapMode: Text.WordWrap
                width: parent.width

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
        ToolIcon {
            iconId: "toolbar-back"
            onClicked: pageStack.pop();
        }
    }
}
