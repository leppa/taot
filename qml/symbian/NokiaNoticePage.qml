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
import com.nokia.symbian 1.1

Page {
    id: root

    property bool platformInverted: false

    ScrollDecorator {
        flickableItem: contents
    }

    Flickable {
        id: contents

        contentWidth: width
        contentHeight: label.height + 2 * platformStyle.paddingMedium
        anchors {
            top: header.bottom
            left: parent.left
            bottom: parent.bottom
            right: parent.right
        }

        Label {
            id: label

            text: "<p><span style='color: red'>Starting from the 1st of January, 2014, <b>Nokia
Store</b> will stop accepting submissions for <b>Symbian</b> and <b>Nokia N9</b> applications.
</span> This means that there will be no way to provide any updates or fixes to <i>The Advanced
Online Translator</i> through the <b>Nokia Store</b>.</p>

<p>If you would like to update <i>The Advanced Online Translator</i> after this date, please, visit
the <a href='https://github.com/leppa/taot/wiki/Nokia-Store-Freeze'>
https://github.com/leppa/taot/wiki/Nokia-Store-Freeze</a> page. It will provide information about
how to upgrade <i>The Advanced Online Translator</i> for <b>Symbian</b> and <b>Nokia N9</b> starting
from the year 2014.</p>

<p>Meanwhile, all updates to <i>The Advanced Online Translator</i> will be provided through the
<b>Nokia Store</b> until the end of 2013.</p>

<p><b>NOTE:</b> You can always access this notice from the application main menu.</p>"
            platformInverted: root.platformInverted
            wrapMode: Text.Wrap
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: platformStyle.paddingMedium
            }

            onLinkActivated: {
                Qt.openUrlExternally(link);
            }
        }
    }

    Rectangle {
        id: header

        height: platformStyle.graphicSizeMedium
        gradient: Gradient {
            GradientStop {
                position: 0.00
                color: platformStyle.colorNormalLink
            }
            GradientStop {
                position: 1.0
                color: Qt.darker(platformStyle.colorNormalLink)
            }
        }
        anchors {
            left: parent.left
            right: parent.right
        }

        Label {
            text: qsTr("Important Information")
            color: "white"
            font.pixelSize: platformStyle.fontSizeLarge
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: platformStyle.paddingMedium
            }
        }
    }

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back"
            platformInverted: root.platformInverted
            onClicked: pageStack.pop();
        }
    }
}
