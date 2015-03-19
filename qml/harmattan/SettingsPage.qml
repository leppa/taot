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
import "constants.js" as UI

Page {
    id: root

    Header {
        id: header
        text: qsTr("%1 Settings").arg("TAO Translator")
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
            }

            ListDelegate {
                title: qsTr("Interface Language");
                subTitle: l10n.get(l10n.currentIndex).name
                anchors {
                    left: parent.left
                    right: parent.right
                }

                onClicked: {
                    languages.selectedIndex = l10n.currentIndex;
                    languages.open();
                }
            }

            Item {
                height: childrenRect.height
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: UI.MARGIN_XLARGE
                    rightMargin: UI.MARGIN_XLARGE
                }

                Column {
                    id: invertedThemeLabels

                    anchors {
                        left: parent.left
                        right: invertedThemeSwitch.left
                        rightMargin: 8 /*UI.PADDING_LARGE*/
                    }

                    Label {
                        text: qsTr("Dark Theme")
                        color: theme.inverted ? UI.LIST_TITLE_COLOR_INVERTED
                                              : UI.LIST_TITLE_COLOR
                        font {
                            weight: Font.Bold
                            pixelSize: UI.LIST_TILE_SIZE
                        }
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                    }
                    Label {
                        text: qsTr("Use dark color scheme")
                        color: theme.inverted ? UI.LIST_SUBTITLE_COLOR_INVERTED
                                              : UI.LIST_SUBTITLE_COLOR
                        font {
                            weight: UI.LIST_SUBTILE_SIZE
                            pixelSize: Font.Light
                        }
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                    }
                }
                Switch {
                    id: invertedThemeSwitch

                    checked: theme.inverted
                    anchors {
                        right: parent.right
                        verticalCenter: invertedThemeLabels.verticalCenter
                    }

                    onCheckedChanged: {
                        theme.inverted = checked;
                        translator.setSettingsValue("InvertedTheme", theme.inverted);
                    }
                }
            }
        }
    }

    ScrollDecorator {
        flickableItem: scrollArea
    }

    Menu {
        id: menu

        MenuLayout {
            MenuItem {
                text: qsTr("Send Feedback")
                onClicked: {
                    Qt.openUrlExternally("mailto:contacts" + "@"
                                         + "oleksii.name?subject=TAO%20Translator%20Feedback"
                                         + "%20(Nokia%20N9)");
                }
            }
            MenuItem {
                text: qsTr("Check for Updates")
                onClicked: {
                    pageStack.push(updateCheckerPageComponent);
                }
            }
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(aboutPageComponent);
            }
        }
    }

    SelectionDialog {
        id: languages
        titleText: qsTr("Interface Language")
        model: l10n
        onSelectedIndexChanged: {
            l10n.currentLanguage = l10n.get(selectedIndex).language;
        }
    }

    L10nModel {
        id: l10n

        onCurrentLanguageChanged: {
            banner.text = qsTr("Please, restart the application to apply this setting.");
            banner.show();
        }
    }

    Component {
        id: aboutPageComponent
        AboutPage {}
    }

    Component {
        id: updateCheckerPageComponent
        UpdateCheckerPage {}
    }

    tools: ToolBarLayout {
        ToolIcon {
            iconId: "toolbar-back"
            onClicked: pageStack.pop();
        }
        ToolIcon {
            iconId: "toolbar-view-menu"
            onClicked: menu.open();
        }
    }
}
