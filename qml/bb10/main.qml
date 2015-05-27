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

import bb.cascades 1.0
import bb.system 1.0
import taot 1.0

NavigationPane {
    id: navigationPane

    property bool translateOnEnter: translator.getSettingsValue("TranslateOnEnter", false)

    onTranslateOnEnterChanged: {
        translator.setSettingsValue("TranslateOnEnter", translateOnEnter);
    }

    MainPage {}

    Menu.definition: MenuDefinition {
        id: menuDefinition

        actions: [
            ActionItem {
                title: qsTr("About") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///icons/ic_info.png"

                onTriggered: {
                    Application.menuEnabled = false;
                    navigationPane.push(aboutPageDefinition.createObject());
                }
            },
            ActionItem {
                title: qsTr("Send feedback") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///icons/ic_feedback.png"

                onTriggered: {
                    translator.invoke("sys.pim.uib.email.hybridcomposer", "bb.action.SENDEMAIL",
                                      "mailto:contacts" + "@"
                                      + "oleksii.name?subject=TAO%20Translator%20v"
                                      + encodeURIComponent(translator.version)
                                      + "%20Feedback%20(BlackBerry%2010)");
                }
            },
            ActionItem {
                title: qsTr("Write a review") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///icons/ic_edit_bookmarks.png"

                onTriggered: {
                    translator.invoke("sys.appworld",
                                      "bb.action.OPEN",
                                      "appworld://content/21908039");
                }
            }
        ]
        settingsAction: SettingsActionItem {
            title: qsTr("Settings") + Retranslate.onLocaleOrLanguageChanged
            onTriggered: {
                Application.menuEnabled = false;
                navigationPane.push(settingsPageDefinition.createObject());
            }
        }
    }

    attachedObjects: [
        ComponentDefinition {
            id: aboutPageDefinition
            AboutPage {}
        },
        ComponentDefinition {
            id: settingsPageDefinition
            SettingsPage {}
        },
        SystemToast {
            id: toast
            button.label: qsTr("Close")
        }
    ]

    onPopTransitionEnded: {
        // Destroy the popped Page once the back transition has ended.
        page.destroy();
        Application.menuEnabled = true;
    }

    function onError(errorString)
    {
        console.debug(errorString);
        toast.body = errorString;
        toast.show();
    }

    onCreationCompleted: {
        translator.error.connect(onError);
    }
}
