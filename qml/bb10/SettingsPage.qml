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

            Container {
                layout: DockLayout {}

                StandardListItem {
                    title: qsTr("Dark Theme") + Retranslate.onLocaleOrLanguageChanged
                    description: qsTr("Use dark color scheme")
                                 + Retranslate.onLocaleOrLanguageChanged
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Center

                    gestureHandlers: [
                        TapHandler {
                            onTapped: {
                                invertedTheme.checked = !invertedTheme.checked;
                                toast.body = qsTr("Please, restart the application"
                                                  + " to apply this setting.");
                                toast.show();
                            }
                        }
                    ]
                }

                Container {
                    rightPadding: 20
                    horizontalAlignment: HorizontalAlignment.Right
                    verticalAlignment: VerticalAlignment.Center

                    ToggleButton {
                        id: invertedTheme

                        gestureHandlers: [
                            TapHandler {
                                onTapped: {
                                    toast.body = qsTr("Please, restart the application"
                                                      + " to apply this setting.");
                                    toast.show();
                                }
                            }
                        ]

                        onCheckedChanged: {
                            translator.setSettingsValue("InvertedTheme", invertedTheme.checked);
                        }
                    }
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
        invertedTheme.checked = translator.getSettingsValue("InvertedTheme",
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
