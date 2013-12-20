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
import taot 1.0

Page {
    id: page

    SilicaFlickable {
        contentHeight: column.height + Theme.paddingMedium
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(aboutPageComponent);
            }

            MenuItem {
                text: qsTr("Translation Service")
                onClicked: pageStack.push(servicePicker);
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

                onTextChanged: {
                    if (translator.sourceText === text)
                        return;

                    translator.sourceText = text;
                }
            }

            Row {
                height: childrenRect.height
                spacing: Theme.paddingSmall
                clip: true
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }

                Button {
                    width: (parent.width - parent.spacing) / 2
                    text: qsTr("Translate")
                    enabled: !translator.busy

                    onClicked: translator.translate();
                }
                Button {
                    width: (parent.width - parent.spacing) / 2
                    text: qsTr("Clear")
                    enabled: source.text != ""

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
                text: translator.translatedText
                width: parent.width
                height: translator.supportsTranslation ? implicitHeight
                                                       : 0
                visible: height > 0
//                readOnly: true
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

    BusyIndicator {
        size: BusyIndicatorSize.Large
        running: translator.busy
        anchors.centerIn: parent
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
        id: aboutPageComponent

        AboutPage {}
    }

    Translator {
        id: translator

        onError: {
            console.debug(errorString);
            banner.show(errorString);
        }
    }
}
