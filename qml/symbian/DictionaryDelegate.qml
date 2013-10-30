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

import QtQuick 1.1
import com.nokia.symbian 1.1

MouseArea {
    id: root

    width: ListView.view.width
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

            ListItemText {
                id: pos

                role: "SubTitle"
                text: model.pos
            }
            ListItemText {
                id: translations

                width: parent.width
                role: "Title"
                text: model.translations
                clip: true
                wrapMode: Text.WordWrap
                elide: Text.ElideNone
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
                    height: reverse.childrenRect.height
                }
                PropertyChanges {
                    target: translations
                    height: undefined
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
                leftMargin: platformStyle.paddingMedium
                right: parent.right
            }

            Repeater {
                model: reverseTranslations

                delegate: Item {
                    width: parent.width
                    height: Math.max(term.height, revTranslations.height)

                    ListItemText {
                        id: term

                        width: posDelegate.maxWidth
                        role: "Heading"
                        text: model.term
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideNone
                        anchors {
                            top: parent.top
                            topMargin: platformStyle.paddingSmall
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
                    ListItemText {
                        id: revTranslations

                        role: "Title"
                        text: model.translations
                        wrapMode: Text.WordWrap
                        elide: Text.ElideNone
                        anchors {
                            left: term.right
                            leftMargin: platformStyle.paddingLarge
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
            color: platformStyle.colorNormalLight
        }
    }

    Image {
        id: indicator

        source: Qt.resolvedUrl("icons/expand.png")
        sourceSize {
            width: platformStyle.graphicSizeTiny
            height: platformStyle.graphicSizeTiny
        }
        anchors {
            top: posDelegate.bottom
            topMargin: -height / 4 - 1
            right: parent.right
        }
    }
}
