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

import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: root

    function show(text)
    {
        label.text = text;
        anchors.bottomMargin = 0;
        timer.restart();
    }

    color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
    height: childrenRect.height
    anchors {
        left: parent.left
        bottom: parent.bottom
        bottomMargin: -height
        right: parent.right
    }

    Behavior on anchors.bottomMargin {
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    Timer {
        id: timer

        interval: 3000
        repeat: false
        onTriggered: {
            anchors.bottomMargin = -height;
        }
    }

    Label {
        id: label

        color: Theme.highlightColor
        height: implicitHeight + 2 * Theme.paddingMedium
        wrapMode: Text.Wrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors {
            left: parent.left
            leftMargin: Theme.paddingMedium
            right: parent.right
            rightMargin: Theme.paddingMedium
        }
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            timer.stop();
            root.anchors.bottomMargin = -root.height;
        }
    }
}
