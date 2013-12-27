/*
 *  The Advanced Online Translator
 *  Copyright (C) 2013  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
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

import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    id: root

    x: Theme.paddingLarge
    width: implicitWidth - 2 * x
    height: posDelegate.height + indicator.height / 2 + Theme.paddingSmall

    onClicked: {
        posDelegate.toggle();
    }

    Column {
        id: posDelegate

        property real maxWidth: 0

        width: parent.width
        anchors {
            top: parent.top
            topMargin: Theme.paddingSmall
        }

        function toggle()
        {
            state = (state == "") ? "Expanded" : ""
        }

        Item {
            id: postrans

            width: parent.width
            height: pos.height + translations.height

            Label {
                id: pos

                text: model.pos
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
            }
            Label {
                id: translations

                width: parent.width
                text: model.translations
                clip: true
                wrapMode: Text.WordWrap
                elide: Text.ElideNone
                font.pixelSize: Theme.fontSizeSmall
                anchors {
                    top: pos.bottom
                    left: parent.left
                    right: parent.right
                }
            }
        }

        Column {
            id: reverse

            height: 0
            clip: true
            anchors {
                left: parent.left
                leftMargin: Theme.paddingSmall
                right: parent.right
            }

            Repeater {
                model: reverseTranslations

                Item {
                    width: parent.width
                    height: Math.max(term.y + term.height, revTranslations.height)

                    Label {
                        id: term

                        width: posDelegate.maxWidth
                        text: model.term + (model.synonyms.length > 0
                                            ? "\n(" + model.synonyms + ")"
                                            : "")
                        horizontalAlignment: Text.AlignRight
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideNone
                        font.pixelSize: (Theme.fontSizeTiny + Theme.fontSizeSmall) / 2
                        anchors {
                            baseline: revTranslations.baseline
                            left: parent.left
                        }

                        Component.onCompleted: {
                            if (posDelegate.maxWidth < implicitWidth) {
                                if (implicitWidth < posDelegate.width * 0.38)
                                    posDelegate.maxWidth = implicitWidth;
                                else
                                    posDelegate.maxWidth = posDelegate.width * 0.38;
                            }
                        }
                    }
                    Label {
                        id: revTranslations

                        text: model.translations
                        wrapMode: Text.WordWrap
                        elide: Text.ElideNone
                        anchors {
                            left: term.right
                            leftMargin: Theme.paddingMedium
                            right: parent.right
                        }
                    }
                }
            }
        }

        states: [
            State {
                name: "Expanded"
                PropertyChanges {
                    target: reverse
                    height: undefined
                }
                PropertyChanges {
                    target: translations
                    height: translations.implicitHeight
                    wrapMode: Text.NoWrap
                    elide: Text.ElideRight
                }
                PropertyChanges {
                    target: line
                    anchors.topMargin: indicator.height / 4 + 3
                }
                PropertyChanges {
                    target: indicator
                    rotation: 180
                }
            }
        ]

        transitions: [
            Transition {
                reversible: true

                ParallelAnimation {
                    SequentialAnimation {
                        NumberAnimation { targets: translations; property: "height"; duration: 400; easing.type: Easing.InOutQuad }
                        PropertyAction { target: translations; properties: "wrapMode,elide" }
                    }
                    NumberAnimation { targets: [reverse,line,indicator]; properties: "height,anchors.topMargin"; duration: 400; easing.type: Easing.InOutQuad }
                    SequentialAnimation {
                        NumberAnimation { target: indicator; property: "height"; from: indicator.height; to: 0; duration: 200; easing.type: Easing.InQuad }
                        PropertyAction { target: indicator; property: "rotation" }
                        NumberAnimation { target: indicator; property: "height"; from: 0; to: indicator.height; duration: 200; easing.type: Easing.OutQuad }
                    }
                }
            }
        ]
    }

    Rectangle {
        id: line

        height: 2
        anchors {
            top: posDelegate.bottom
            left: parent.left
            right: parent.right
        }
        border {
            width: 1
            color: "#ffffff"
        }
    }

    Image {
        id: indicator

        source: Qt.resolvedUrl("icons/expand.png")
        sourceSize {
            width: Theme.iconSizeSmall
            height:Theme.iconSizeSmall
        }
        anchors {
            top: posDelegate.bottom
            topMargin: -height / 4 - 1
            right: parent.right
        }
    }
}
