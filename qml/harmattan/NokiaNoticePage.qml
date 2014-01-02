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

import QtQuick 1.1
import com.nokia.meego 1.1

Page {
    id: root

    Header {
        id: header
        text: qsTr("Important Information")
    }

    Flickable {
        id: scrollArea

        contentHeight: label.height + 2 * 8 /*UI.PADDING_LARGE*/
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
            wrapMode: Text.Wrap
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 8 /*UI.PADDING_LARGE*/
            }

            onLinkActivated: {
                Qt.openUrlExternally(link);
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
