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

import QtQuick 1.1
import com.nokia.symbian 1.1
import taot 1.0

Page {
    id: root

    property bool platformInverted: false

    Header {
        id: header
        text: qsTr("%1 Settings").arg("TAO Translator")
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
            }

            SelectionListItem {
                title: qsTr("Interface Language");
                subTitle: l10n.get(l10n.currentIndex).name
                platformInverted: root.platformInverted
                anchors {
                    left: parent.left
                    right: parent.right
                }

                onClicked: {
                    languages.selectedIndex = l10n.currentIndex;
                    languages.open();
                }
            }

            SettingsSwitch {
                title: qsTr("Dark Theme")
                description: qsTr("Use dark color scheme")
                checked: !appWindow.platformInverted
                platformInverted: root.platformInverted

                onCheckedChanged: {
                    appWindow.platformInverted = !checked;
                    translator.setSettingsValue("InvertedTheme", appWindow.platformInverted);
                }
            }

            SettingsSwitch {
                title: qsTr("Translate on Enter Press")
                description: qsTr("Only one line of text is supported in this mode")
                checked: translateOnEnter
                platformInverted: root.platformInverted

                onCheckedChanged: {
                    translateOnEnter = checked;
                }
            }

            SettingsSwitch {
                title: qsTr("Paste'n'Translate")
                description: qsTr("Automatically start translation after inserting text with"
                                  + " <em>Paste</em> button")
                checked: translateOnPaste
                platformInverted: root.platformInverted

                onCheckedChanged: {
                    translateOnPaste = checked;
                }
            }

            Button {
                text: qsTr("Privacy Settings")
                visible: analytics_enabled
                platformInverted: root.platformInverted
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                onClicked: {
                    pageStack.push(privacyNoticePage);
                }
            }
        }
    }

    ScrollDecorator {
        flickableItem: scrollArea
        platformInverted: root.platformInverted
    }

    Menu {
        id: menu
        platformInverted: root.platformInverted

        MenuLayout {
            MenuItem {
                text: qsTr("Send Feedback")
                platformInverted: root.platformInverted
                onClicked: {
                    Qt.openUrlExternally("mailto:contacts" + "@"
                                         + "oleksii.name?subject=TAO%20Translator%20v"
                                         + encodeURIComponent(translator.version)
                                         + "%20Feedback%20(Symbian)");
                }
            }
            MenuItem {
                text: qsTr("Check for Updates")
                platformInverted: root.platformInverted
                onClicked: {
                    pageStack.push(updateCheckerPageComponent);
                }
            }
            MenuItem {
                text: qsTr("About")
                platformInverted: root.platformInverted
                onClicked: pageStack.push(aboutPageComponent);
            }
        }
    }

    SelectionDialog {
        id: languages
        titleText: qsTr("Interface Language")
        model: l10n
        platformInverted: root.platformInverted
        delegate: ListDelegate {
            text: model.name
            privateSelectionIndicator: selectedIndex === model.index
            platformInverted: root.platformInverted
            onClicked: {
                selectedIndex = model.index;
                l10n.currentLanguage = model.language;
                languages.accept();
            }
        }
    }

    L10nModel {
        id: l10n

        onCurrentLanguageChanged: {
            banner.text = qsTr("Please, restart the application to apply this setting.");
            banner.open();
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
