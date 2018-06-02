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

import QtQuick 1.1
import com.nokia.meego 1.1
import "constants.js" as UI

MouseArea {
    id: root

    height: posDelegate.height + indicator.height / 2

    onClicked: {
        posDelegate.toggle();
    }

    ListView.onAdd: SequentialAnimation {
        PropertyAction {
            target: root
            properties: "scale,opacity"
            value: 0
        }
        PauseAnimation {
            duration: model.index < 0 ? 0 : 50 * (model.index + 1)
        }
        NumberAnimation {
            target: root
            properties: "scale,opacity"
            to: 1
            duration: 200
            easing.type: Easing.OutBack
        }
    }
    ListView.onRemove: SequentialAnimation {
        PropertyAction { target: root; property: "ListView.delayRemove"; value: true }
        PropertyAction {
            target: root
            property: "clip"
            value: true
        }
        NumberAnimation {
            target: root
            properties: "height"
            to: 0
            duration: 300
            easing.type: Easing.InQuad
        }
        PropertyAction { target: root; property: "ListView.delayRemove"; value: false }
    }

    Column {
        id: posDelegate

        property real maxWidth: 0

        width: parent.width

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
                color: theme.inverted ? UI.LIST_SUBTITLE_COLOR_INVERTED : UI.LIST_SUBTITLE_COLOR
                font.pixelSize: UI.LIST_SUBTILE_SIZE
            }
            Label {
                id: translations

                width: parent.width
                text: model.translations
                clip: true
                wrapMode: Text.WordWrap
                elide: Text.ElideNone
                color: theme.inverted ? UI.LIST_TITLE_COLOR_INVERTED : UI.LIST_TITLE_COLOR
                font.pixelSize: UI.LIST_TILE_SIZE
                anchors {
                    top: pos.bottom
                    left: parent.left
                    right: parent.right
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

        Column {
            id: reverse

            height: 0
            clip: true
            anchors {
                left: parent.left
                leftMargin: 6 /*UI.PADDING_MEDIUM*/
                right: parent.right
            }

            Repeater {
                model: reverseTranslations

                delegate: Item {
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
                        font.pixelSize: UI.LIST_SUBTILE_SIZE
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
                            leftMargin: 12 /*UI.PADDING_DOUBLE*/
                            right: parent.right
                        }
                    }
                }
            }
        }
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
            color: theme.inverted ? "#ffffff" /*UI.COLOR_INVERTED_FOREGROUND*/
                                  : "#191919" /*UI.COLOR_FOREGROUND*/
        }
    }

    Image {
        id: indicator

        source: Qt.resolvedUrl("icons/expand.png")
        sourceSize {
            width: 32 /*UI.SIZE_ICON_DEFAULT*/
            height: 32 /*UI.SIZE_ICON_DEFAULT*/
        }
        anchors {
            top: posDelegate.bottom
            topMargin: -height / 4 - 1
            right: parent.right
        }
    }
}
