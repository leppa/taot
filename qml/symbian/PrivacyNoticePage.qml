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
import com.nokia.symbian 1.1
import Qt.labs.components 1.1
import taot 1.0

import "privacy.js" as Privacy

Page {
    id: root

    property bool platformInverted: false

    Header {
        id: header
        text: qsTr("Privacy Notice")
    }

    Flickable {
        id: scrollArea

        contentHeight: column.height + 2 * platformStyle.paddingLarge
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
                margins: platformStyle.paddingLarge
            }

            Label {
                text: Privacy.notice
                width: parent.width
                wrapMode: Text.WordWrap
                platformInverted: root.platformInverted
                font.pixelSize: platformStyle.fontSizeLarge
            }

            CheckableGroup {
                id: privacySelector

                property int selectedLevel
            }
            RadioButton {
                text: Privacy.noPrivacyText
                platformExclusiveGroup: privacySelector
                checked: translator.privacyLevel == Translator.NoPrivacy
                platformInverted: root.platformInverted

                onCheckedChanged: {
                    if (checked)
                        privacySelector.selectedLevel = Translator.NoPrivacy;
                }
            }
            RadioButton {
                text: Privacy.errorsOnlyText
                platformExclusiveGroup: privacySelector
                checked: translator.privacyLevel == Translator.ErrorsOnlyPrivacy
                platformInverted: root.platformInverted

                onCheckedChanged: {
                    if (checked)
                        privacySelector.selectedLevel = Translator.ErrorsOnlyPrivacy;
                }
            }
            RadioButton {
                text: Privacy.maxPrivacyText
                platformExclusiveGroup: privacySelector
                checked: translator.privacyLevel == Translator.MaximumPrivacy
                platformInverted: root.platformInverted

                onCheckedChanged: {
                    if (checked)
                        privacySelector.selectedLevel = Translator.MaximumPrivacy;
                }
            }

            Label {
                text: Privacy.details
                width: parent.width
                wrapMode: Text.WordWrap
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
            text: qsTr("Cancel")
            enabled: translator.privacyLevel != Translator.UndefinedPrivacy
            platformInverted: root.platformInverted
            onClicked: {
                pageStack.pop();
            }
        }
        ToolButton {
            text: qsTr("Accept")
            platformInverted: root.platformInverted
            onClicked: {
                translator.privacyLevel = privacySelector.selectedLevel
                pageStack.pop();
            }
        }
    }
}
