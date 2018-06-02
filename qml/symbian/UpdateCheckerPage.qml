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
import taot 1.0

Page {
    id: root

    property bool platformInverted: false

    Header {
        id: header
        text: qsTr("Update")
    }

    Flickable {
        id: scrollArea

        contentHeight: column.height + 2 * platformStyle.paddingMedium
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
                margins: platformStyle.paddingMedium
            }

            Label {
                width: parent.width
                text: qsTr("Current version: <b>%1</b>").arg(updater.currentVersion)
                platformInverted: root.platformInverted
            }
            Label {
                width: parent.width
                text: qsTr("Checking for update...")
                visible: updater.busy
                platformInverted: root.platformInverted
            }
            Column {
                width: parent.width
                visible: !updater.busy
                spacing: platformStyle.paddingMedium

                Label {
                    width: parent.width
                    text: qsTr("No update available.")
                    visible: !updater.updateAvailable
                    platformInverted: root.platformInverted
                }
                Label {
                    width: parent.width
                    text: qsTr("Update available: <b>%1</b>").arg(updater.latestRelease.version)
                    visible: updater.updateAvailable
                    platformInverted: root.platformInverted
                }
                Label {
                    width: parent.width
                    text: qsTr("Changes:")
                    visible: updater.updateAvailable
                    platformInverted: root.platformInverted
                    font {
                        bold: true
                        pixelSize: platformStyle.fontSizeLarge
                    }
                }
                Label {
                    width: parent.width
                    text: updater.latestRelease.changeLog
                    wrapMode: Text.WordWrap
                    textFormat: Text.PlainText
                    visible: updater.updateAvailable
                    platformInverted: root.platformInverted
                }
            }
        }
    }

    ScrollDecorator {
        flickableItem: scrollArea
        platformInverted: root.platformInverted
    }

    Updater {
        id: updater
        variant: "symbian"
        currentVersion: translator.version
        onError: {
            banner.text = errorString;
            banner.open();
        }
    }

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back"
            platformInverted: root.platformInverted
            onClicked: pageStack.pop();
        }
        ToolButton {
            text: qsTr("Download")
            visible: updater.updateAvailable
            platformInverted: root.platformInverted
            onClicked: {
                Qt.openUrlExternally("https://github.com/leppa/taot/wiki/Symbian");
            }
        }
        ToolButton {
            iconSource: enabled ? "toolbar-refresh" : Qt.resolvedUrl("icons/empty.png")
            enabled: !updater.busy
            platformInverted: root.platformInverted
            onClicked: {
                translator.trackCheckForUpdates();
                updater.checkForUpdates();
            }

            BusyIndicator {
                visible: updater.busy
                running: visible
                platformInverted: root.platformInverted
                anchors.centerIn: parent
            }
        }
    }

    Component.onCompleted: {
        translator.trackCheckForUpdates();
        updater.checkForUpdates();
    }
}
