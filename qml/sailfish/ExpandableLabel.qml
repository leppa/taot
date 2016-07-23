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

import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    property alias text: label.text
    property bool expanded: false
    property bool expandable: expanded || label.truncated

    height: visible ? implicitHeight : 0
    implicitHeight: childrenRect.height
    clip: true

    Label {
        id: label

        wrapMode: Text.Wrap
        elide: Text.ElideNone
        maximumLineCount: expanded ? undefined : 1
        font.pixelSize: Theme.fontSizeSmall
        anchors {
            left: parent.left
            right: parent.right
        }
    }

    OpacityRampEffect {
        sourceItem: label
        direction: OpacityRamp.TopToBottom
        offset: 0.5
        enabled: expandable && !expanded
    }

    Image {
        id: indicator

        source: Qt.resolvedUrl("icons/expand.png")
        rotation: expanded ? 180 : 0
        visible: expanded || (!expanded && expandable)
        height: visible ? implicitHeight : 0
        sourceSize {
            width: Theme.iconSizeSmall
            height: Theme.iconSizeSmall
        }
        anchors {
            top: label.bottom
            topMargin: -height / 4
            right: parent.right
        }

        Behavior on rotation { NumberAnimation {} }
    }

    Behavior on height { NumberAnimation {} }

    onTextChanged: {
        expanded = false;
    }

    onExpandableChanged: {
        if (!expandable && expanded)
            expanded = false;
    }

    onClicked: {
        if (!expandable)
            return;

        expanded = !expanded
    }
}
