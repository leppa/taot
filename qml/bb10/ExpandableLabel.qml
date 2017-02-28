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

import bb.cascades 1.0

Container {
    property alias text: label.text
    property alias textStyle: label.textStyle
    property bool expanded: false

    Label {
        id: label

        multiline: expanded
        topMargin: 0
        bottomMargin: 0
    }
    ImageView {
        imageSource: "asset:///icons/collapse" + (darkTheme ? "_inverted" : "") + ".png"
        topMargin: 0
        bottomMargin: 0
        preferredWidth: 35
        preferredHeight: preferredWidth
        horizontalAlignment: HorizontalAlignment.Right
        visible: expanded
    }
    Divider {
        topMargin: 5
        bottomMargin: 0
    }
    ImageView {
        imageSource: "asset:///icons/expand" + (darkTheme ? "_inverted" : "") + ".png"
        topMargin: 0
        bottomMargin: 0
        preferredWidth: 35
        preferredHeight: preferredWidth
        horizontalAlignment: HorizontalAlignment.Right
        visible: !expanded
    }

    onTextChanged: {
        expanded = false;
    }

    gestureHandlers: [
        TapHandler {
            onTapped: {
                expanded = !expanded;
            }
        }
    ]
}
