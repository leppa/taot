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

import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.taot 1.0

Page {
    id: page

    allowedOrientations: Orientation.Portrait
                         | Orientation.Landscape
                         | Orientation.LandscapeInverted

    SilicaFlickable {
        contentHeight: column.height + Theme.paddingMedium
        anchors.fill: parent

        Column {
            id: column

            spacing: Theme.paddingMedium
            anchors {
                left: parent.left
                right: parent.right
            }

            PageHeader {
                title: qsTr("%1 Settings").arg("TAO Translator")
            }

            ComboBox {
                id: languageCombo

                label: qsTr("Interface Language")
                currentIndex: l10n.currentIndex
                menu: ContextMenu {
                    Repeater {
                        model: l10n

                        MenuItem {
                            text: model.name
                        }
                    }
                }

                onCurrentIndexChanged: {
                    l10n.currentLanguage = l10n.get(currentIndex).language;
                }
            }

            TextSwitch {
                text: qsTr("Translate on Enter Press")
                description: qsTr("Only one line of text is supported in this mode")
                checked: translateOnEnter

                onCheckedChanged: {
                    translateOnEnter = checked;
                }
            }

            TextSwitch {
                text: qsTr("Paste'n'Translate")
                description: qsTr("Automatically start translation after inserting text with"
                                  + " <i>Paste</i> button")
                checked: translateOnPaste

                onCheckedChanged: {
                    translateOnPaste = checked;
                }
            }

            Button {
                text: qsTr("Privacy Settings")
                visible: analytics_enabled
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                onClicked: {
                    pageStack.push(privacyNoticePage);
                }
            }
        }

        VerticalScrollDecorator {}
    }

    L10nModel {
        id: l10n

        onCurrentLanguageChanged: {
            banner.show(qsTr("Please, restart the application to apply this setting."));
        }
    }
}
