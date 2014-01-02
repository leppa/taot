/*
 *  The Advanced Online Translator
 *  Copyright (C) 2013-2014  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
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

import QtQuick 2.0
import Sailfish.Silica 1.0
import "about.js" as About

Page {
    id: root

    SilicaFlickable {
        id: scrollArea

        contentHeight: column.height
        anchors.fill: parent

        Column {
            id: column

            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }

            PageHeader {
                title: qsTr("About")
            }

            Label {
                width: parent.width
                text: "<b>The Advanced Online Translator</b><br />v%1".arg(translator.version)
                color: Theme.highlightColor
                font.family: Theme.fontFamilyHeading
            }

            Label {
                text: About.aboutText
                wrapMode: Text.WordWrap
                width: parent.width
                font.pixelSize: Theme.fontSizeSmall

                onLinkActivated: {
                    Qt.openUrlExternally(translator.urlDecode(link));
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
