/*
 *  TAO Translator
 *  Copyright (C) 2013-2018  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
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

Item {
    id: root

    property alias title: titleLabel.text
    property alias description: descriptionLabel.text
    property alias checked: toggle.checked
    property bool platformInverted: false

    height: childrenRect.height
    anchors {
        left: parent.left
        right: parent.right
        leftMargin: platformStyle.paddingLarge
        rightMargin: platformStyle.paddingLarge
    }

    Column {
        id: labels

        anchors {
            left: parent.left
            right: toggle.left
            rightMargin: platformStyle.paddingSmall
        }

        ListItemText {
            id: titleLabel

            role: "Title"
            elide: Text.ElideNone
            wrapMode: Text.WordWrap
            platformInverted: root.platformInverted
            anchors {
                left: parent.left
                right: parent.right
            }
        }
        ListItemText {
            id: descriptionLabel

            role: "SubTitle"
            elide: Text.ElideNone
            wrapMode: Text.WordWrap
            platformInverted: root.platformInverted
            anchors {
                left: parent.left
                right: parent.right
            }
        }
    }
    Switch {
        id: toggle

        platformInverted: root.platformInverted
        anchors {
            right: parent.right
            verticalCenter: labels.verticalCenter
        }
    }
}
