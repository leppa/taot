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

import QtQuick 1.1
import com.nokia.meego 1.1
import taot 1.0
import "constants.js" as UI

Page {
    // A hack for text item to loose focus when clicked outside of it
    MouseArea {
        id: dummyFocus
        anchors.fill: parent
        onClicked: {
            focus = true;
        }
    }

    SelectionDialog {
        id: servicesDialog
        titleText: qsTr("Translation Service")
        model: translator.services
        onSelectedIndexChanged: {
            translator.selectService(selectedIndex);
        }
    }

    SelectionDialog {
        id: fromDialog
        titleText: qsTr("Source Language")
        model: translator.sourceLanguages
        onSelectedIndexChanged: {
            translator.selectSourceLanguage(selectedIndex);
        }
    }

    SelectionDialog {
        id: toDialog
        titleText: qsTr("Target Language")
        model: translator.targetLanguages
        onSelectedIndexChanged: {
            translator.selectTargetLanguage(selectedIndex);
        }
    }

    Component {
        id: header

        Column {
            id: col

            width: ListView.view.width
            height: childrenRect.height + UiConstants.ButtonSpacing
            spacing: UiConstants.ButtonSpacing

            Row {
                height: fromSelector.height
                spacing: 8 /*UI.PADDING_LARGE*/
                anchors {
                    left: parent.left
                    right: parent.right
                }

                ListDelegate {
                    id: fromSelector

                    width: (parent.width - swap.width - 2 * parent.spacing) / 2
                    title: qsTr("From");
                    subTitle: translator.sourceLanguage.displayName;

                    onClicked: {
                        fromDialog.selectedIndex = translator.sourceLanguages
                                                   .indexOf(translator.sourceLanguage);
                        fromDialog.open();
                    }
                }
                Button {
                    id: swap

                    iconSource: theme.inverted
                                ? "image://theme/icon-m-toolbar-refresh-white-selected"
                                : "image://theme/icon-m-toolbar-refresh-dimmed-white"
                    enabled: translator.canSwapLanguages
                    visible: width != 0
                    width: enabled ? height : 0
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: {
                        translator.swapLanguages();
                    }
                }
                ListDelegate {
                    width: (parent.width - swap.width - 2 * parent.spacing) / 2
                    title: qsTr("To")
                    subTitle: translator.targetLanguage.displayName;

                    onClicked: {
                        toDialog.selectedIndex = translator.targetLanguages
                                                 .indexOf(translator.targetLanguage);
                        toDialog.open();
                    }
                }
            }

            TextArea {
                id: source

                width: parent.width
                height: Math.min(implicitHeight, listDictionary.height * 0.4)
//                text: "Welcome"
                placeholderText: qsTr("Enter the source text...")
                textFormat: TextEdit.PlainText

//                Keys.onReturnPressed: translator.translate();
//                Keys.onEnterPressed: translator.translate();

                onTextChanged: {
                    if (translator.sourceText == text)
                        return;

                    translator.sourceText = text;
                }
            }

            Row {
                width: parent.width
                height: childrenRect.height
                spacing: UiConstants.ButtonSpacing

                Button {
                    width: (parent.width - parent.spacing) / 2
                    text: qsTr("Translate")
                    enabled: !translator.busy
                    platformStyle: ButtonStyle {
                        inverted: !theme.inverted
                    }
                    onClicked: {
                        dummyFocus.focus = true;
                        translator.translate();
                    }

                    BusyIndicator {
                        visible: translator.busy
                        running: visible
                        anchors.centerIn: parent
                    }
                }
                Button {
                    width: (parent.width - parent.spacing) / 2
                    text: qsTr("Clear")
                    enabled: source.text != ""
                    platformStyle: ButtonStyle {
                        inverted: !theme.inverted
                    }
                    onClicked: {
                        source.text = "";
                        source.forceActiveFocus();
                    }
                }

                Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }}
            }

            BorderImage {
                height: translator.supportsTranslation ? trans.implicitHeight
                                                         + (52 /*UI.FIELD_DEFAULT_HEIGHT*/
                                                            - trans.font.pixelSize)
                                                       : 0
                source: source.style.backgroundDisabled
                smooth: true
                clip: true
                border {
                    top: source.style.backgroundCornerMargin
                    left: source.style.backgroundCornerMargin
                    bottom: source.style.backgroundCornerMargin
                    right: source.style.backgroundCornerMargin
                }
                anchors {
                    left: parent.left
                    right: parent.right
                }

                Label {
                    id: trans

                    text: translator.translatedText
                    wrapMode: TextEdit.Wrap
                    color: source.style.textColor
                    font: source.style.textFont
                    anchors {
                        top: parent.top
                        topMargin: (52 /*UI.FIELD_DEFAULT_HEIGHT*/ - font.pixelSize) / 2
                        left: parent.left
                        leftMargin: source.style.paddingLeft
                        right: parent.right
                        rightMargin: source.style.paddingRight
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        dummyFocus.focus = true;
                        if (translator.translatedText != "")
                            pageStack.push(translationPage);
                    }
                }

                Behavior on height {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Row {
                id: detectedLanguage

                width: parent.width
                height: childrenRect.height
                spacing: 4 /*UI.PADDING_SMALL*/
                state: "Empty"
                clip: true

                Label {
                    font.weight: Font.Light
                    text: qsTr("Detected language:")
                }
                Label {
                    id: dl
                    text: translator.detectedLanguageName
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

            Component.onCompleted: {
                listDictionary.headerItem = col;
            }
        }
    }

    Item {
        id: titleBar

        height: appWindow.inPortrait ? UiConstants.HeaderDefaultHeightPortrait
                                     : UiConstants.HeaderDefaultHeightLandscape
        anchors {
            left: parent.left
            right: parent.right
        }

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop {
                    position: 0.00
                    color: theme.selectionColor
                }
                GradientStop {
                    position: 1.0;
                    color: Qt.darker(theme.selectionColor)
                }
            }
        }

        Rectangle {
            color: theme.selectionColor
            visible: mouseArea.pressed
            anchors.fill: parent
        }

        MouseArea {
            id: mouseArea
            enabled: parent.enabled
            anchors.fill: parent
            onClicked: {
                if (servicesDialog.selectedIndex < 0)
                    servicesDialog.selectedIndex = translator.selectedService.index;
                servicesDialog.open();
            }
        }

        Label {
            color: "white"
            text: translator.selectedService.name
            font: UiConstants.HeaderFont
            anchors {
                left: parent.left
                leftMargin: UiConstants.DefaultMargin
                verticalCenter: parent.verticalCenter
            }
        }

        Image {
            id: icon

            height: sourceSize.height
            width: sourceSize.width
            source: "image://theme/meegotouch-combobox-indicator-inverted"
            anchors {
                right: parent.right
                rightMargin: UI.MARGIN_XLARGE
                verticalCenter: parent.verticalCenter
            }
        }
    }

    ListView {
        id: listDictionary

        property Item headerItem

        clip: true
        model: translator.dictionary
        interactive: visibleArea.heightRatio < 1.0 || (headerItem.height > height - 2 * UiConstants.ButtonSpacing)
        // HACK: We need this to save the exapnded state of translation.
        // TODO: Come up with more appropriate solution.
        cacheBuffer: 65535
        anchors {
            top: titleBar.bottom
            left: parent.left
            leftMargin: 8 /*UI.PADDING_LARGE*/
            bottom: parent.bottom
            right: parent.right
            rightMargin: 8 /*UI.PADDING_LARGE*/
        }

        header: header
        delegate: DictionaryDelegate {
            onClicked: {
                dummyFocus.focus = true;
            }
        }

        onMovementStarted: {
            dummyFocus.focus = true;
        }
    }

    ScrollDecorator {
        flickableItem: listDictionary
    }

    tools: ToolBarLayout {
        ToolIcon {
            iconId: "toolbar-close"
            onClicked: Qt.quit();
        }
        ToolIcon {
            iconId: "toolbar-view-menu"
            onClicked: mainMenu.open();
        }
    }

    Menu {
        id: mainMenu

        MenuLayout {
            MenuItem {
                text: qsTr("Toggle Inverted Theme")
                onClicked: {
                    theme.inverted = !theme.inverted;
                    translator.setSettingsValue("InvertedTheme", theme.inverted);
                }
            }
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(aboutPageComponent);
            }
        }
    }

    Translator {
        id: translator

        onError: {
            console.debug(errorString);
            banner.text = errorString;
            banner.show();
        }
    }

    Component {
        id: translationPage
        TranslationTextAreaPage {}
    }

    Component {
        id: aboutPageComponent
        AboutPage {}
    }

    Component.onCompleted: {
        theme.inverted = translator.getSettingsValue("InvertedTheme");
    }
}
