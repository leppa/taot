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
import com.nokia.meego 1.1

MouseArea {
    id: root

    property string text
    property bool expanded: false
    property bool expandable: controlLabel.width > label.width

    height: visible ? implicitHeight : 0
    implicitHeight: childrenRect.height
    clip: true

    TextAreaStyle {
        id: style
    }

    Label {
        id: label

        text: expanded ? root.text : root.text.replace(/\r|\n/g, " ")
        wrapMode: expanded ? Text.WordWrap : Text.NoWrap
        elide: expanded ? Text.ElideNone : Text.ElideRight
        width: parent.width - style.backgroundCornerMargin
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: style.backgroundCornerMargin / 2
            rightMargin: style.backgroundCornerMargin / 2
        }
    }

    Image {
        id: indicator

        source: Qt.resolvedUrl("icons/expand.png")
        rotation: expanded ? 180 : 0
        visible: expanded || (!expanded && expandable)
        height: visible ? implicitHeight : 0
        sourceSize {
            width: 32 /*UI.SIZE_ICON_DEFAULT*/
            height: 32 /*UI.SIZE_ICON_DEFAULT*/
        }
        anchors {
            top: label.bottom
            topMargin: -height / 4
            right: parent.right
            rightMargin: style.backgroundCornerMargin / 2
        }

        Behavior on rotation { NumberAnimation {} }
    }

    Behavior on height { NumberAnimation {} }

    // HACK: Text::truncated property
    // doesn't seem to work properly,
    // so this hack is used to detect,
    // whether text fits on one line.
    property Label controlLabel: Label {
        text: root.text.replace(/\r|\n/g, "")
        maximumLineCount: 1
        visible: false
    }

    onTextChanged: {
        expanded = false;
    }

    onExpandableChanged: {
        if (!expandable)
            expanded = false;
    }

    onClicked: {
        if (!expandable)
            return;

        expanded = !expanded
    }
}
