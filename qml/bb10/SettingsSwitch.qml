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

import bb.cascades 1.0

Container {
    id: root

    property alias title: title.text
    property alias description: description.text
    property alias checked: toggle.checked
    property int padding: 10

    signal tapped()

    layout: StackLayout { orientation: LayoutOrientation.LeftToRight }
    topPadding: padding
    leftPadding: padding
    bottomPadding: padding
    rightPadding: padding

    Container {
        verticalAlignment: VerticalAlignment.Center
        layoutProperties: StackLayoutProperties {
            spaceQuota: 1
        }

        Label {
            id: title

            multiline: true
            bottomMargin: 0
            textStyle {
                base: SystemDefaults.TextStyles.TitleText
            }
        }
        Label {
            id: description

            multiline: true
            topMargin: 0
            textFormat: TextFormat.Html
            visible: text != ""
            textStyle {
                base: SystemDefaults.TextStyles.SubTitleText
                fontWeight: FontWeight.W300
            }
        }

        gestureHandlers: [
            TapHandler {
                onTapped: {
                    toggle.checked = !toggle.checked;
                    root.tapped();
                }
            }
        ]
    }

    Container {
        leftPadding: 10
        verticalAlignment: VerticalAlignment.Center
        layoutProperties: StackLayoutProperties {
            spaceQuota: -1
        }

        ToggleButton {
            id: toggle

            gestureHandlers: [
                TapHandler {
                    onTapped: {
                        root.tapped();
                    }
                }
            ]
        }
    }
}
