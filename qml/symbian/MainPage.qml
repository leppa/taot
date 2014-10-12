/*
 *  TAO Translator
 *  Copyright (C) 2013-2014  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
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
import com.nokia.symbian 1.1
import taot 1.0

Page {
    id: root

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

    ScrollDecorator {
        flickableItem: flickable
    }

    Item {
        id: titleBar

        width: parent.width
        height: platformStyle.graphicSizeMedium
        enabled: source.state != "Active"

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
            visible: opacity > 0
            opacity: parent.enabled ? 1.0 : 0.0
            sourceSize {
                width: platformStyle.graphicSizeSmall
                height: platformStyle.graphicSizeSmall
            }
            anchors {
                right: parent.right
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }

            Behavior on opacity { NumberAnimation { duration: 100 } }
        }
    }

    Flickable {
        id: flickable

        clip: true
        contentWidth: content.width
        contentHeight: content.height
        anchors {
            top: titleBar.bottom
            left: parent.left
            leftMargin: platformStyle.paddingSmall
            bottom: parent.bottom
            right: parent.right
            rightMargin: platformStyle.paddingSmall
        }

        Column {
            id: content

            width: flickable.width
            height: childrenRect.height + 2 * platformStyle.paddingMedium
            spacing: platformStyle.paddingMedium
            y: platformStyle.paddingMedium

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

            Item {
                id: sourceWrapper

                z: 1
                width: parent.width
                height: source.implicitHeight

                TextArea {
                    id: source

                    width: parent.width
                    height: parent.height
//                    text: "Welcome"
                    placeholderText: qsTr("Enter the source text...")
                    textFormat: TextEdit.PlainText
                    platformInverted: appWindow.platformInverted

                    onTextChanged: {
                        if (translator.sourceText == text)
                            return;

                        translator.sourceText = text;
                    }

                    states: [
                        State {
                            name: "Active"
                            when: source.activeFocus
                                  && (inputContext.visible
                                      // HACK: There are some cases, where VKB is visible,
                                      // but reported as not. This is a dirty workaround.
                                      || translator.appVisibility == Translator.AppPartiallyVisible)
                            ParentChange {
                                target: source
                                parent: root
                                x: platformStyle.paddingSmall
                                y: titleBar.height + platformStyle.paddingSmall
                                width: parent.width - 2 * platformStyle.paddingSmall
                                height: parent.height - titleBar.height
                                        - 2 * platformStyle.paddingSmall
                            }
                        }
                    ]

                    transitions: [
                        Transition {
                            from: "*"
                            to: "Active"
                            reversible: true
                            ParentAnimation {
                                target: source

                                PropertyAnimation {
                                    duration: 100
                                    easing.type: Easing.InOutQuad
                                    properties: "y"
                                }
                                PropertyAnimation {
                                    duration: 100
                                    easing.type: Easing.InOutQuad
                                    properties: "height"
                                }
                            }
                        }
                    ]
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
                        translator.translate();
                    }

                    BusyIndicator {
                        visible: translator.busy
                        running: visible
                        platformInverted: appWindow.platformInverted
                        anchors.centerIn: parent
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

            Column {
                id: listDictionary

                width: parent.width
                height: childrenRect.height

                Repeater {
                    model: translator.dictionary
                    delegate: DictionaryDelegate {
                        width: listDictionary.width
                        platformInverted: appWindow.platformInverted
                    }
                }
            }
        }
    }

    Rectangle {
        color: appWindow.platformInverted ? platformStyle.colorBackgroundInverted
                                          : platformStyle.colorBackground
        visible: opacity > 0
        opacity: source.state == "Active" ? 1.0 : 0.0
        anchors {
            top: titleBar.bottom
            left: parent.left
            bottom: parent.bottom
            right: parent.right
        }

        MouseArea {
            enabled: parent.visible
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            anchors.fill: parent
        }

        Behavior on opacity { NumberAnimation { duration: 100 }}
    }

    tools: ToolBarLayout {
        ToolButton {
            iconSource: Qt.resolvedUrl(platformInverted ? "icons/close_inverted.svg"
                                                        : "icons/close.svg")
            platformInverted: appWindow.platformInverted
            onClicked: Qt.quit();
        }
        ToolButton {
            iconSource: "toolbar-settings"
            platformInverted: appWindow.platformInverted
            onClicked: pageStack.push(settingsPage);
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
        id: settingsPage
        SettingsPage {
            platformInverted: appWindow.platformInverted
        }
    }

    Component.onCompleted: {
        appWindow.platformInverted = translator.getSettingsValue("InvertedTheme");
    }
}
