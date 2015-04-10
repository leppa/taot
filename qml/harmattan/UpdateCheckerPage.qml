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
import com.nokia.meego 1.1
import taot 1.0

Page {
    Header {
        id: header
        text: qsTr("Update")
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
                text: qsTr("Current version: <b>%1</b>").arg(updater.currentVersion)
            }
            Label {
                width: parent.width
                text: qsTr("Checking for update...")
                visible: updater.busy
            }
            Column {
                width: parent.width
                visible: !updater.busy
                spacing: 8 /*UI.PADDING_LARGE*/

                Label {
                    width: parent.width
                    text: qsTr("No update available.")
                    visible: !updater.updateAvailable
                }
                Label {
                    width: parent.width
                    text: qsTr("Update available: <b>%1</b>").arg(updater.latestRelease.version)
                    visible: updater.updateAvailable
                }
                Label {
                    width: parent.width
                    text: qsTr("Changes:")
                    font: UiConstants.TitleFont
                    visible: updater.updateAvailable
                }
                Label {
                    width: parent.width
                    text: updater.latestRelease.changeLog
                    wrapMode: Text.WordWrap
                    textFormat: Text.PlainText
                    visible: updater.updateAvailable
                }
                Button {
                    text: qsTr("Download")
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: updater.updateAvailable
                    onClicked: {
                        Qt.openUrlExternally("https://github.com/leppa/taot/wiki/Nokia-N9");
                    }
                }
            }
        }
    }

    ScrollDecorator {
        flickableItem: scrollArea
    }

    Updater {
        id: updater
        variant: "harmattan"
        currentVersion: translator.version
        onError: {
            banner.text = errorString;
            banner.show();
        }
    }

    tools: ToolBarLayout {
        ToolIcon {
            iconId: "toolbar-back"
            onClicked: pageStack.pop();
        }
        ToolIcon {
            iconId: "toolbar-refresh"
            iconSource: enabled ? "" : Qt.resolvedUrl("icons/empty.png")
            enabled: !updater.busy
            onClicked: {
                updater.checkForUpdates();
            }

            BusyIndicator {
                visible: updater.busy
                running: visible
                anchors.centerIn: parent
            }
        }
    }

    Component.onCompleted: {
        updater.checkForUpdates();
    }
}
