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
import com.nokia.meego 1.1
import taot 1.0

import "constants.js" as UI
import "privacy.js" as Privacy

Sheet {
    id: root

    acceptButtonText: qsTr("Accept")
    rejectButtonText: translator.privacyLevel != Translator.UndefinedPrivacy ? qsTr("Cancel")
                                                                             : ""

    content: [
        Flickable {
        id: scrollArea

        contentHeight: column.height + 2 * UI.MARGIN_XLARGE
        anchors {
            fill: parent
        }

        Column {
            id: column

            property int selectedOption

            function checkItem(option)
            {
                noPrivacyOption.checked = option === Translator.NoPrivacy;
                errorsOnlyOption.checked = option === Translator.ErrorsOnlyPrivacy;
                maxPrivacyOption.checked = option === Translator.MaximumPrivacy;
                selectedOption = option;
            }

            spacing: UI.MARGIN_XLARGE
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: UI.MARGIN_XLARGE
            }

            Label {
                text: Privacy.notice
                width: parent.width
                wrapMode: Text.WordWrap
                font: UiConstants.TitleFont
            }

            RadioButton {
                id: noPrivacyOption
                text: Privacy.noPrivacyText
                checked: translator.privacyLevel == Translator.NoPrivacy
                         || translator.privacyLevel == Translator.UndefinedPrivacy

                function __handleChecked() {
                    column.checkItem(Translator.NoPrivacy);
                }
            }
            RadioButton {
                id: errorsOnlyOption
                text: Privacy.errorsOnlyText
                checked: translator.privacyLevel == Translator.ErrorsOnlyPrivacy

                function __handleChecked() {
                    column.checkItem(Translator.ErrorsOnlyPrivacy);
                }
            }
            RadioButton {
                id: maxPrivacyOption
                text: Privacy.maxPrivacyText
                checked: translator.privacyLevel == Translator.MaximumPrivacy

                function __handleChecked() {
                    column.checkItem(Translator.MaximumPrivacy);
                }
            }

            Label {
                text: Privacy.details
                width: parent.width
                wrapMode: Text.WordWrap

                onLinkActivated: {
                    Qt.openUrlExternally(link);
                }
            }
        }
    },
        ScrollDecorator {
            flickableItem: scrollArea
        }
    ]

    onAccepted: {
        translator.privacyLevel = column.selectedOption;
    }
}
