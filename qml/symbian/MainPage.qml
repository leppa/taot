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
import com.nokia.symbian 1.1
import taot 1.0

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
        platformInverted: appWindow.platformInverted
        delegate: ListDelegate {
            text: model.name
            privateSelectionIndicator: selectedIndex === model.index
            platformInverted: appWindow.platformInverted
            onClicked: {
                selectedIndex = model.index;
                translator.selectService(model.index);
                servicesDialog.accept();
            }
        }
    }

    SelectionDialog {
        id: fromDialog
        titleText: qsTr("Source Language")
        model: translator.sourceLanguages
        platformInverted: appWindow.platformInverted
        delegate: ListDelegate {
            text: model.name
            privateSelectionIndicator: selectedIndex === model.index
            platformInverted: appWindow.platformInverted
            onClicked: {
                selectedIndex = model.index;
                translator.selectSourceLanguage(model.index);
                fromDialog.accept();
            }
        }
    }

    SelectionDialog {
        id: toDialog
        titleText: qsTr("Target Language")
        model: translator.targetLanguages
        platformInverted: appWindow.platformInverted
        delegate: ListDelegate {
            text: model.name
            privateSelectionIndicator: selectedIndex === model.index
            platformInverted: appWindow.platformInverted
            onClicked: {
                selectedIndex = model.index;
                translator.selectTargetLanguage(model.index);
                toDialog.accept();
            }
        }
    }

    Component {
        id: header

        Column {
            id: col

            width: ListView.view.width
            height: childrenRect.height + platformStyle.paddingMedium
            spacing: platformStyle.paddingMedium

            Row {
                width: parent.width
                height: fromSelector.height
                spacing: platformStyle.paddingSmall

                SelectionListItem {
                    id: fromSelector

                    width: (parent.width - swap.width - 2 * parent.spacing) / 2
                    title: qsTr("From");
                    subTitle: translator.sourceLanguage.displayName
                    platformInverted: appWindow.platformInverted

                    onClicked: {
                        fromDialog.selectedIndex = translator.sourceLanguages
                                                   .indexOf(translator.sourceLanguage);
                        fromDialog.open();
                    }
                }
                Button {
                    id: swap

                    iconSource: Qt.resolvedUrl(appWindow.platformInverted
                                               ? "icons/swap_inverted.png"
                                               : "icons/swap.png")
                    enabled: translator.canSwapLanguages
                    visible: width != 0
                    width: enabled ? implicitWidth : 0
                    platformInverted: appWindow.platformInverted
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: {
                        translator.swapLanguages();
                    }

                    Behavior on width {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
                SelectionListItem {
                    width: (parent.width - swap.width - 2 * parent.spacing) / 2
                    title: qsTr("To")
                    subTitle: translator.targetLanguage.displayName
                    platformInverted: appWindow.platformInverted

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
                platformInverted: appWindow.platformInverted

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
                spacing: platformStyle.paddingMedium

                Button {
                    width: (parent.width - parent.spacing) / 2
                    text: qsTr("Translate")
                    enabled: !translator.busy
                    platformInverted: !appWindow.platformInverted
                    onClicked: {
                        dummyFocus.focus = true;
                        translator.translate();
                    }
                }
                Button {
                    width: (parent.width - parent.spacing) / 2
                    text: qsTr("Clear")
                    enabled: source.text != ""
                    platformInverted: !appWindow.platformInverted
                    onClicked: {
                        source.text = "";
                        source.forceActiveFocus();
                    }
                }

                Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }}
            }

            BorderImage {
                height: translator.supportsTranslation ? trans.implicitHeight
                                                         + platformStyle.borderSizeMedium / 2
                                                         + 2 * platformStyle.paddingMedium
                                                       : 0
                source: privateStyle.imagePath("qtg_fr_textfield_uneditable",
                                               appWindow.platformInverted)
                smooth: true
                clip: true
                border {
                    top: platformStyle.borderSizeMedium
                    left: platformStyle.borderSizeMedium
                    bottom: platformStyle.borderSizeMedium
                    right: platformStyle.borderSizeMedium
                }
                anchors {
                    left: parent.left
                    right: parent.right
                }

                Label {
                    id: trans

                    text: translator.translatedText
                    wrapMode: TextEdit.Wrap
                    color: platformStyle.colorNormalDark
                    platformInverted: appWindow.platformInverted
                    anchors {
                        top: parent.top
                        topMargin: platformStyle.borderSizeMedium / 4 + platformStyle.paddingMedium
                        left: parent.left
                        leftMargin: platformStyle.borderSizeMedium / 2 + platformStyle.paddingSmall
                        right: parent.right
                        rightMargin: platformStyle.borderSizeMedium / 2 + platformStyle.paddingSmall
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
                spacing: platformStyle.paddingSmall
                state: "Empty"
                clip: true

                Label {
                    font.weight: Font.Light
                    text: qsTr("Detected language:")
                    platformInverted: appWindow.platformInverted
                }
                Label {
                    id: dl
                    text: translator.detectedLanguageName
                    platformInverted: appWindow.platformInverted
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

    Rectangle {
        z: 100
        color: platformInverted ? platformStyle.colorBackgroundInverted
                                : platformStyle.colorBackground
        opacity: translator.busy ? 0.5 : 0.0
        visible: opacity != 0
        anchors.fill: parent

        BusyIndicator {
            width: platformStyle.graphicSizeLarge
            height: width
            running: parent.visible
            platformInverted: appWindow.platformInverted
            anchors.centerIn: parent
        }

        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    ScrollDecorator {
        flickableItem: listDictionary
    }

    Item {
        id: titleBar

        width: parent.width
        height: platformStyle.graphicSizeMedium

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop {
                    position: 0.00
                    color: platformStyle.colorNormalLink
                }
                GradientStop {
                    position: 1.0;
                    color: Qt.darker(platformStyle.colorNormalLink)
                }
            }
        }

        Rectangle {
            color: platformStyle.colorNormalLink
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
            font.pixelSize: platformStyle.fontSizeLarge
            platformInverted: appWindow.platformInverted
            anchors {
                left: parent.left
                leftMargin: platformStyle.paddingLarge
                verticalCenter: parent.verticalCenter
            }
        }

        Image {
            id: icon

            source: "image://theme/qtg_graf_choice_list_indicator"
            sourceSize {
                width: platformStyle.graphicSizeSmall
                height: platformStyle.graphicSizeSmall
            }
            anchors {
                right: parent.right
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
        }
    }

    ListView {
        id: listDictionary

        property Item headerItem

        clip: true
        model: translator.dictionary
        interactive: visibleArea.heightRatio < 1.0 || (headerItem.height > height - 2 * platformStyle.paddingMedium)
        // HACK: We need this to save the exapnded state of translation.
        // TODO: Come up with more appropriate solution.
        cacheBuffer: 65535
        anchors {
            top: titleBar.bottom
            left: parent.left
            leftMargin: platformStyle.paddingSmall
            bottom: parent.bottom
            right: parent.right
            rightMargin: platformStyle.paddingSmall
        }

        header: header
        delegate: DictionaryDelegate {
            platformInverted: appWindow.platformInverted
            onClicked: {
                dummyFocus.focus = true;
            }
        }

        onMovementStarted: {
            dummyFocus.focus = true;
        }
    }

    tools: ToolBarLayout {
        ToolButton {
            iconSource: Qt.resolvedUrl(platformInverted ? "icons/close_inverted.svg"
                                                        : "icons/close.svg")
            platformInverted: appWindow.platformInverted
            onClicked: Qt.quit();
        }
        ToolButton {
            iconSource: "toolbar-menu"
            platformInverted: appWindow.platformInverted
            onClicked: mainMenu.open();
        }
    }

    Menu {
        id: mainMenu
        platformInverted: appWindow.platformInverted

        MenuLayout {
            MenuItem {
                text: qsTr("Toggle Inverted Theme")
                platformInverted: appWindow.platformInverted
                onClicked: {
                    appWindow.platformInverted = !appWindow.platformInverted;
                    translator.setSettingsValue("InvertedTheme", appWindow.platformInverted);
                }
            }
            MenuItem {
                text: qsTr("About")
                platformInverted: appWindow.platformInverted
                onClicked: pageStack.push(aboutPageComponent);
            }
        }
    }

    Translator {
        id: translator

        onError: {
            console.debug(errorString);
            banner.text = errorString;
            banner.open();
        }
    }

    Component {
        id: translationPage
        TranslationTextAreaPage {
            platformInverted: appWindow.platformInverted
        }
    }

    Component {
        id: aboutPageComponent

        AboutPage {
            platformInverted: appWindow.platformInverted
        }
    }

    Component.onCompleted: {
        appWindow.platformInverted = translator.getSettingsValue("InvertedTheme");
    }
}
