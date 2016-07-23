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

import QtQuick 1.0
import bb.cascades 1.0
import taot 1.0

import "privacy.js" as Privacy

Sheet {
    id: root

    Page {
        titleBar: TitleBar {
            title: qsTr("Privacy Notice") + Retranslate.onLocaleOrLanguageChanged

            dismissAction: ActionItem {
                title: qsTr("Cancel") + Retranslate.onLocaleOrLanguageChanged
                enabled: translator.privacyLevel != Translator.UndefinedPrivacy

                onTriggered: {
                    root.close();
                }
            }
            acceptAction: ActionItem {
                title: qsTr("Accept") + Retranslate.onLocaleOrLanguageChanged

                onTriggered: {
                    translator.privacyLevel = privacySelector.selectedIndex;
                    root.close();
                }
            }
        }

        ScrollView {
            Container {
                property int padding: 20

                topPadding: padding
                leftPadding: padding
                bottomPadding: padding
                rightPadding: padding

                Label {
                    text: Privacy.notice + Retranslate.onLocaleOrLanguageChanged
                    multiline: true
                    textStyle {
                        base: SystemDefaults.TextStyles.TitleText
                    }
                }
                RadioGroup {
                    id: privacySelector

                    selectedIndex: translator.privacyLevel == Translator.UndefinedPrivacy
                                   ? Translator.NoPrivacy
                                   : translator.privacyLevel
                    dividersVisible: true

                    Option {
                        text: Privacy.noPrivacyText + Retranslate.onLocaleOrLanguageChanged
                    }
                    Option {
                        text: Privacy.errorsOnlyText + Retranslate.onLocaleOrLanguageChanged
                    }
                    Option {
                        text: Privacy.maxPrivacyText + Retranslate.onLocaleOrLanguageChanged
                    }
                }
                Label {
                    text: Privacy.details + Retranslate.onLocaleOrLanguageChanged
                    textFormat: TextFormat.Html
                    multiline: true
                }
            }
        }
    }
}
