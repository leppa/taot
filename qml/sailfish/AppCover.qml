/*
 *  TAO Translator
 *  Copyright (C) 2013-2017  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
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

CoverBackground {
    id: root

    property bool swapped: false

    CoverPlaceholder {
        Label {
            text: root.swapped ? qsTr("From: <b>%1</b>").arg(translator.sourceLanguage.displayName)
                               : qsTr("To: <b>%1</b>").arg(translator.targetLanguage.displayName)
            color: Theme.secondaryHighlightColor
            width: parent.width - 2 * Theme.paddingMedium
            horizontalAlignment: Text.AlignHCenter
            fontSizeMode: Text.Fit
            visible: translator.translatedText
            maximumLineCount: 2
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeExtraSmall
            anchors {
                top: parent.top
                topMargin: Theme.paddingLarge
                horizontalCenter: parent.horizontalCenter
            }
        }

        text: translator.translatedText ? !root.swapped ? translator.translatedText
                                                        : translator.sourceText
                                        : "TAO Translator"
        icon.source: translator.translatedText ? "" : Qt.resolvedUrl("icons/icon.png")
    }

    CoverActionList {
        enabled: translator.translatedText

        CoverAction {
            iconSource: Qt.resolvedUrl("icons/swap.png")

            onTriggered: {
                root.swapped = !root.swapped;
            }
        }
    }
}
