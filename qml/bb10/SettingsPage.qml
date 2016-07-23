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

import bb.cascades 1.0
import taot 1.0

Page {
    id: root

    titleBar: TitleBar {
        //: %1 will be replaced with the application name
        title: qsTr("%1 Settings").arg("TAO Translator")
    }

    ScrollView {
        Container {
            property int padding: 15

            topPadding: padding
            leftPadding: padding
            bottomPadding: padding
            rightPadding: padding

            DropDown {
                id: languages

                title: qsTr("Interface Language") + Retranslate.onLocaleOrLanguageChanged

                onSelectedIndexChanged: {
                    l10n.currentLanguage = selectedValue;
                }
            }

            SettingsSwitch {
                id: invertedThemeSwitch

                title: qsTr("Dark Theme") + Retranslate.onLocaleOrLanguageChanged
                description: qsTr("Use dark color scheme")
                             + Retranslate.onLocaleOrLanguageChanged

                onTapped: {
                    toast.body = qsTr("Please, restart the application to apply this setting.");
                    toast.show();
                }

                onCheckedChanged: {
                    translator.setSettingsValue("InvertedTheme", checked);
                }
            }

            SettingsSwitch {
                id: translateOnEnterSwitch

                title: qsTr("Translate on Enter Press") + Retranslate.onLocaleOrLanguageChanged
                description: qsTr("Hold <em>Shift</em> while pressing <em>Enter</em>"
                                  + " to start a new line")
                             + Retranslate.onLocaleOrLanguageChanged
                checked: translateOnEnter

                onCheckedChanged: {
                    translateOnEnter = checked;
                }
            }

            SettingsSwitch {
                title: qsTr("Paste'n'Translate") + Retranslate.onLocaleOrLanguageChanged
                description: qsTr("Automatically start translation after inserting text with"
                                  + " <em>Paste</em> button")
                             + Retranslate.onLocaleOrLanguageChanged
                checked: translateOnPaste

                onCheckedChanged: {
                    translateOnPaste = checked;
                }
            }
            Button {
                text: qsTr("Privacy Settings")
                horizontalAlignment: HorizontalAlignment.Center
                visible: analytics_enabled

                onClicked: {
                    var page = privacyNoticePageDefinition.createObject();
                    page.closed.connect(function() { page.destroy(); });
                    page.open();
                }
            }
        }
    }

    attachedObjects: [
        ComponentDefinition {
            id: option
            Option {}
        },
        L10nModel {
            id: l10n

            onCurrentLanguageChanged: {
                toast.body = qsTr("Please, restart the application to apply this setting.");
                toast.show();
            }
        }
    ]

    onCreationCompleted: {
        invertedThemeSwitch.checked = translator.getSettingsValue("InvertedTheme",
                Application.themeSupport.theme.colorTheme.style === VisualStyle.Dark);

        for (var k = 0; k < l10n.count; k++) {
            var opt = option.createObject();
            var lang = l10n.get(k);
            opt.text = lang.name;
            opt.value = lang.language;
            opt.selected = (l10n.currentIndex === k);
            languages.add(opt);
        }
    }
}
