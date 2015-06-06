/*
 *  TAO Translator
 *  Copyright (C) 2013-2015  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
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

Page {
    id: page

    property bool translateOnEnter: false

    onTranslateOnEnterChanged: {
        translator.setSettingsValue("TranslateOnEnter", translateOnEnter);
    }

    allowedOrientations: Orientation.Portrait
                         | Orientation.Landscape
                         | Orientation.LandscapeInverted

    SilicaFlickable {
        contentHeight: column.height + Theme.paddingMedium
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Settings")
                onClicked: {
                    pageStack.push(settingsPage);
                }
            }

            MenuItem {
                text: qsTr("Translation Service")
                onClicked: {
                    pageStack.push(servicePicker);
                }
            }
            MenuLabel {
                text: translator.selectedService.name
            }
        }

        Column {
            id: column
            width: page.width

            Row {
                height: Math.max(fromComboBox.height, toComboBox.height)
                anchors {
                    left: parent.left
                    right: parent.right
                }

                ValueButton {
                    id: fromComboBox

                    width: (parent.width - swap.width) / 2
                    label: qsTr("From")
                    value: translator.sourceLanguage.displayName
                    anchors.verticalCenter: parent.verticalCenter

                    onClicked: {
                        pageStack.push(sourceLanguagePicker, {
                                           currentIndex: translator
                                                         .sourceLanguages
                                                         .indexOf(translator.sourceLanguage)
                                       });
                    }
                }

                IconButton {
                    id: swap

                    icon.source: Qt.resolvedUrl("icons/swap.png")
                    enabled: translator.canSwapLanguages
                    visible: width != 0
                    width: enabled ? Theme.itemSizeSmall : 0
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: translator.swapLanguages();
                }

                ValueButton {
                    id: toComboBox

                    width: (parent.width - swap.width) / 2
                    label: qsTr("To")
                    value: translator.targetLanguage.displayName
                    anchors.verticalCenter: parent.verticalCenter

                    onClicked: {
                        pageStack.push(targetLangugePicker, {
                                           currentIndex: translator
                                                         .targetLanguages
                                                         .indexOf(translator.targetLanguage)
                                       });
                    }
                }
            }

            TextArea {
                id: source

                width: parent.width
                placeholderText: qsTr("Enter the source text...")
                labelVisible: false

                onTextChanged: {
                    if (translator.sourceText === text)
                        return;

                    translator.sourceText = text;
                }

                EnterKey.iconSource: translateOnEnter
                                     ? "image://theme/icon-m-enter-accept"
                                     : "image://theme/icon-m-enter"
                EnterKey.enabled: !translateOnEnter
                                  || (!translator.busy && text != "")
                EnterKey.onClicked: {
                    if (!translateOnEnter)
                        return;

                    if (_editor)
                        _editor.undo();
                    translator.translate();
                }
            }

            ExpandableLabel {
                text: translator.transcription.sourceText
                visible: translator.transcription.sourceText != ""
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
            }

            ExpandableLabel {
                text: translator.translit.sourceText
                visible: translator.translit.sourceText != ""
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
            }

            Item {
                height: Math.max(translateButton.height, clearButton.height)
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }

                Button {
                    id: translateButton
                    text: qsTr("Translate")
                    enabled: !translator.busy && source.text != ""
                    anchors {
                        left: parent.left
                        right: clearButton.left
                        rightMargin: Theme.paddingSmall
                        verticalCenter: parent.verticalCenter
                    }

                    onClicked: translator.translate();

                    BusyIndicator {
                        size: BusyIndicatorSize.Small
                        visible: translator.busy
                        running: visible
                        anchors.centerIn: parent
                    }
                }
                IconButton {
                    id: clearButton
                    enabled: source.text != ""
                    icon.source: "image://theme/icon-m-clear"
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }

                    onClicked: {
                        source.text = "";
                        source.forceActiveFocus();
                    }
                }

                Behavior on height {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            TextArea {
                id: translation

                text: translator.translatedText
                width: parent.width
                height: translator.supportsTranslation ? implicitHeight
                                                       : 0
                visible: height > 0
                labelVisible: false
                readOnly: true
                focusOnClick: true

                Separator {
                    color: translation.color
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        bottomMargin: -Theme.paddingSmall / 2
                    }
                }
            }

            ExpandableLabel {
                text: translator.transcription.translatedText
                visible: translator.transcription.translatedText != ""
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
            }

            ExpandableLabel {
                text: translator.translit.translatedText
                visible: translator.translit.translatedText != ""
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
            }

            Row {
                id: detectedLanguage

                height: childrenRect.height
                spacing: Theme.paddingSmall
                state: "Empty"
                clip: true
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }

                Label {
                    text: qsTr("Detected language:")
                    color: Theme.secondaryColor
                    font {
                        pixelSize: Theme.fontSizeSmall
                        weight: Font.Light
                    }
                }
                Label {
                    id: dl
                    text: translator.detectedLanguageName
                    font.pixelSize: Theme.fontSizeSmall
                }

                states: [
                    State {
                        name: "Empty"
                        when: translator.detectedLanguageName === ""

                        PropertyChanges {
                            target: detectedLanguage
                            height: 0
                            opacity: 0
                            scale: 0
                        }
                        PropertyChanges {
                            target: dl
                            text: ""
                        }
                    }
                ]

                transitions: [
                    Transition {
                        from: ""
                        to: "Empty"

                        ParallelAnimation {
                            NumberAnimation {
                                target: detectedLanguage
                                property: "height"
                                duration: 1300
                                easing.type: Easing.OutBack
                            }
                            SequentialAnimation {
                                PauseAnimation {
                                    duration: 1300
                                }
                                PropertyAction {
                                    targets: [detectedLanguage,dl]
                                    properties: "scale,opacity,text"
                                }
                            }
                        }
                    },
                    Transition {
                        from: "Empty"
                        to: ""

                        SequentialAnimation {
                            PropertyAction {
                                targets: [detectedLanguage,dl]
                                properties: "height,text"
                            }
                            NumberAnimation {
                                target: detectedLanguage
                                properties: "scale,opacity"
                                duration: 300
                                easing.type: Easing.OutBack
                            }
                        }
                    }
                ]
            }

            Repeater {
                model: translator.dictionary
                DictionaryDelegate {
                    implicitWidth: column.width
                }
            }
        }
    }

    Component {
        id: servicePicker

        PickerPage {
            title: qsTr("Translation Service")
            model: translator.services
            currentIndex: translator.selectedService.index
            onSelected: {
                pageStack.pop();
                translator.selectService(index);
            }
        }
    }

    Component {
        id: sourceLanguagePicker

        PickerPage {
            title: qsTr("Source Language")
            model: translator.sourceLanguages
            onSelected: {
                pageStack.pop();
                translator.selectSourceLanguage(index);
            }
        }
    }

    Component {
        id: targetLangugePicker

        PickerPage {
            title: qsTr("Target Language")
            model: translator.targetLanguages
            onSelected: {
                pageStack.pop();
                translator.selectTargetLanguage(index);
            }
        }
    }

    Component {
        id: settingsPage

        SettingsPage {}
    }

    Component.onCompleted: {
        translateOnEnter = translator.getSettingsValue("TranslateOnEnter",
                                                       "false") === "true";
    }
}
