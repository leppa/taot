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
import "privacy.js" as Privacy

Dialog {
    id: root

    backNavigation: translator.privacyLevel != Translator.UndefinedPrivacy
    allowedOrientations: Orientation.Portrait
                         | Orientation.Landscape
                         | Orientation.LandscapeInverted

    SilicaFlickable {
        id: scrollArea

        contentHeight: column.height
        anchors.fill: parent

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

            anchors {
                left: parent.left
                right: parent.right
            }

            DialogHeader {
                title: qsTr("Privacy Notice")
            }

            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }

                Label {
                    text: Privacy.notice
                    width: parent.width
                    wrapMode: Text.WordWrap
                    color: Theme.highlightColor
                    font.family: Theme.fontFamilyHeading
                }

                TextSwitch {
                    id: noPrivacyOption
                    text: Privacy.noPrivacyText
                    checked: translator.privacyLevel == Translator.NoPrivacy
                             || translator.privacyLevel == Translator.UndefinedPrivacy
                    automaticCheck: false

                    onClicked: {
                        column.checkItem(Translator.NoPrivacy);
                    }
                }
                TextSwitch {
                    id: errorsOnlyOption
                    text: Privacy.errorsOnlyText
                    checked: translator.privacyLevel == Translator.ErrorsOnlyPrivacy
                    automaticCheck: false

                    onClicked: {
                        column.checkItem(Translator.ErrorsOnlyPrivacy);
                    }
                }
                TextSwitch {
                    id: maxPrivacyOption
                    text: Privacy.maxPrivacyText
                    checked: translator.privacyLevel == Translator.MaximumPrivacy
                    automaticCheck: false

                    onClicked: {
                        column.checkItem(Translator.MaximumPrivacy);
                    }
                }

                Label {
                    text: Privacy.details
                    width: parent.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeExtraSmall

                    onLinkActivated: {
                        Qt.openUrlExternally(link);
                    }
                }
            }
        }

        VerticalScrollDecorator {}
    }

    onAccepted: {
        translator.privacyLevel = column.selectedOption;
    }
}
