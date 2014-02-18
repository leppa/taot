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
import taot 1.0

Container {
    property bool expanded: false

    bottomMargin: expanded ? 15 : 0

    Label {
        text: pos
        topMargin: 0
        bottomMargin: 0
    }
    Label {
        text: translations
        multiline: !expanded
        topMargin: 0
        bottomMargin: 0
        textStyle {
            base: SystemDefaults.TextStyles.PrimaryText
        }
    }
    Repeater {
        model: reverseTranslations

        Container {
            visible: expanded
            layout: StackLayout { orientation: LayoutOrientation.LeftToRight }

            Container {
                topPadding: 12
                layoutProperties: StackLayoutProperties { spaceQuota: 1 }

                Label {
                    text: term + (synonyms.length > 0 ? "\n(" + synonyms + ")" : "")
                    multiline: true
                    topMargin: 0
                    bottomMargin: 0
                    horizontalAlignment: HorizontalAlignment.Fill
                    textStyle {
                        fontSize: FontSize.Small
                        textAlign: TextAlign.Right
                    }
                }
            }
            Container {
                topPadding: 5
                leftPadding: 15
                layoutProperties: StackLayoutProperties { spaceQuota: 2 }

                Divider {
                    topMargin: 0
                    bottomMargin: 0
                }
                Label {
                    text: translations
                    multiline: true
                    topMargin: 0
                    bottomMargin: 0
                }
            }
        }
    }
    ImageView {
        imageSource: "asset:///icons/collapse.png"
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
        imageSource: "asset:///icons/expand.png"
        topMargin: 0
        bottomMargin: 0
        preferredWidth: 35
        preferredHeight: preferredWidth
        horizontalAlignment: HorizontalAlignment.Right
        visible: !expanded
    }

    gestureHandlers: [
        TapHandler {
            onTapped: {
                expanded = !expanded;
            }
        }
    ]
}
