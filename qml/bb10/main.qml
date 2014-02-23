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

import bb.cascades 1.0
import bb.system 1.0
import taot 1.0

NavigationPane {
    id: navigationPane

    MainPage {}

    Menu.definition: MenuDefinition {
        id: menuDefinition

        actions: [
            ActionItem {
                title: qsTr("About") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///icons/ic_info.png"

                onTriggered: {
                    Application.menuEnabled = false;
                    navigationPane.popTransitionEnded
                                  .connect(menuDefinition.reactivateApplicationMenu);
                    navigationPane.push(aboutPageDefinition.createObject());
                }
            }
        ]

        function reactivateApplicationMenu() {
            Application.menuEnabled = true;
            navigationPane.popTransitionEnded.disconnect(menuDefinition.reactivateApplicationMenu);
        }
    }

    attachedObjects: [
        ComponentDefinition {
            id: aboutPageDefinition
            AboutPage {}
        },
        SystemToast {
            id: toast
        }
    ]

    onPopTransitionEnded: {
        // Destroy the popped Page once the back transition has ended.
        page.destroy();
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
