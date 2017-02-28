/*
 *  TAO Translator
 *  Copyright (C) 2013-2017  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
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

    property bool translateOnEnter: translator.getSettingsValue("TranslateOnEnter", false)
    property bool translateOnPaste: translator.getSettingsValue("TranslateOnPaste", true)
    property Item source: translateOnEnter ? sourceSingle : sourceMulti

    onTranslateOnEnterChanged: {
        translator.setSettingsValue("TranslateOnEnter", translateOnEnter);
        if (translateOnEnter) {
            sourceSingle.text = sourceMulti.text;
            sourceMulti.text = "";
        } else {
            sourceMulti.text = sourceSingle.text;
            sourceSingle.text = "";
        }
    }

    onTranslateOnPasteChanged: {
        translator.setSettingsValue("TranslateOnPaste", translateOnPaste);
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

    ScrollDecorator {
        flickableItem: flickable
    }

    Item {
        id: titleBar

        property bool active: true

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
            visible: parent.active && mouseArea.pressed
            anchors.fill: parent
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                if (parent.active) {
                    if (servicesDialog.selectedIndex < 0)
                        servicesDialog.selectedIndex = translator.selectedService.index;
                    servicesDialog.open();
                } else {
                    translateButton.focus = true;
                }
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
            opacity: parent.active ? 1.0 : 0.0
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
            leftMargin: platformStyle.paddingMedium
            bottom: parent.bottom
            right: parent.right
            rightMargin: platformStyle.paddingMedium
        }

        Column {
            id: content

            width: flickable.width
            height: childrenRect.height + 2 * spacing
            spacing: platformStyle.paddingMedium

            Row {
                id: languageSelectors

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
                    id: toSelector

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

                width: parent.width
                height: source.height

                TextField {
                    id: sourceSingle

                    width: parent.width
                    placeholderText: qsTr("Enter the source text...")
                    platformInverted: appWindow.platformInverted
                    visible: translateOnEnter
                    onTextChanged: {
                        if (!visible || translator.sourceText == text)
                            return;

                        translator.sourceText = text;
                    }

                    Keys.onEnterPressed: {
                        translateButton.focus = true;
                        translator.translate();
                    }
                }

                TextArea {
                    id: sourceMulti

                    width: parent.width
                    height: implicitHeight
//                    text: "Welcome"
                    placeholderText: qsTr("Enter the source text...")
                    textFormat: TextEdit.PlainText
                    platformInverted: appWindow.platformInverted
                    visible: !translateOnEnter

                    onTextChanged: {
                        if (!visible || translator.sourceText == text)
                            return;

                        translator.sourceText = text;
                    }
                }
            }

            Column {
                id: sourceExpandables
                width: parent.width
                height: childrenRect.height
                spacing: parent.spacing

                ExpandableLabel {
                    text: translator.transcription.sourceText
                    visible: translator.transcription.sourceText != ""
                    platformInverted: appWindow.platformInverted
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                }

                ExpandableLabel {
                    text: translator.translit.sourceText
                    visible: translator.translit.sourceText != ""
                    platformInverted: appWindow.platformInverted
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                }
            }

            Item {
                id: buttonRow

                implicitHeight: Math.max(translateButton.height, clearButton.height)
                anchors {
                    left: parent.left
                    right: parent.right
                }

                Button {
                    id: translateButton
                    text: qsTr("Translate")
                    enabled: !translator.busy
                    platformInverted: !appWindow.platformInverted
                    anchors {
                        left: parent.left
                        right: clearButton.left
                        rightMargin: platformStyle.paddingMedium
                        verticalCenter: parent.verticalCenter
                    }
                    onClicked: {
                        focus = true;
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
                    id: clearButton
                    iconSource: Qt.resolvedUrl(platformInverted ? "icons/close_inverted.svg"
                                                                : "icons/close.svg")
                    enabled: source.text != ""
                    platformInverted: !appWindow.platformInverted
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
                        duration: 200; easing.type: Easing.InOutQuad
                    }
                }
            }

            Column {
                id: bottom
                width: parent.width
                height: childrenRect.height
                spacing: parent.spacing

                BorderImage {
                    id: translation

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
                            topMargin: platformStyle.borderSizeMedium / 4
                                       + platformStyle.paddingMedium
                            left: parent.left
                            leftMargin: platformStyle.borderSizeMedium / 2
                                        + platformStyle.paddingSmall
                            right: parent.right
                            rightMargin: platformStyle.borderSizeMedium / 2
                                         + platformStyle.paddingSmall
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

                ExpandableLabel {
                    text: translator.transcription.translatedText
                    visible: translator.transcription.translatedText != ""
                    platformInverted: appWindow.platformInverted
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                }

                ExpandableLabel {
                    text: translator.translit.translatedText
                    visible: translator.translit.translatedText != ""
                    platformInverted: appWindow.platformInverted
                    anchors {
                        left: parent.left
                        right: parent.right
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
    }

    Menu {
        id: menu
        platformInverted: appWindow.platformInverted

        MenuLayout {
            MenuItem {
                text: qsTr("Settings")
                platformInverted: appWindow.platformInverted
                onClicked: {
                    pageStack.push(settingsPage);
                }
            }
            MenuItem {
                text: qsTr("Send Feedback")
                platformInverted: appWindow.platformInverted
                onClicked: {
                    Qt.openUrlExternally("mailto:contacts"
                                         + "@"
                                         + "oleksii.name?subject=TAO%20Translator%20v"
                                         + encodeURIComponent(translator.version)
                                         + "%20Feedback%20(Symbian)");
                }
            }
            MenuItem {
                text: qsTr("Check for Updates")
                platformInverted: appWindow.platformInverted
                onClicked: {
                    pageStack.push(updateCheckerPageComponent);
                }
            }
            MenuItem {
                text: qsTr("About")
                platformInverted: appWindow.platformInverted
                onClicked: {
                    pageStack.push(aboutPageComponent);
                }
            }
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
            text: qsTr("Paste")
            enabled: !clipboard.empty
            platformInverted: appWindow.platformInverted
            onClicked: {
                if (translateOnPaste) {
                    source.text = clipboard.text;
                    translator.translate();
                } else {
                    source.paste();
                }
            }
        }
        ToolButton {
            text: qsTr("Copy")
            enabled: translator.translatedText != ""
            platformInverted: appWindow.platformInverted
            onClicked: {
                clipboard.insert(translator.translatedText);
            }
        }
        ToolButton {
            iconSource: "toolbar-menu"
            platformInverted: appWindow.platformInverted
            onClicked: {
                menu.open();
            }
        }
    }

    Translator {
        id: translator

        onError: {
            banner.text = errorString;
            banner.open();
        }
        onInfo: {
            banner.text = infoString;
            banner.open();
        }
    }

    Clipboard {
        id: clipboard
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

    Connections {
        target: Qt.application
        onActiveChanged: {
            console.debug("Application active", Qt.application.active);
        }
    }

    Component {
        id: privacyNoticePage
        PrivacyNoticePage {
            platformInverted: appWindow.platformInverted
        }
    }

    Component {
        id: updateCheckerPageComponent
        UpdateCheckerPage {
            platformInverted: appWindow.platformInverted
        }
    }

    Component {
        id: aboutPageComponent
        AboutPage {
            platformInverted: appWindow.platformInverted
        }
    }

    states: [
        State {
            name: "Active"
            when: Qt.application.active
                  && (sourceMulti.activeFocus || (sourceSingle.activeFocus && !inPortrait))
                  && (inputContext.visible
                      // HACK: There are some cases, where VKB is visible,
                      // but reported as not. This is a dirty workaround.
                      || translator.appVisibility == Translator.AppPartiallyVisible)

            PropertyChanges {
                target: titleBar
                active: false
            }
            PropertyChanges {
                target: flickable
            }
            PropertyChanges {
                target: content
                y: platformStyle.paddingMedium
                height: content.y + sourceWrapper.height + content.spacing + buttonRow.height
                        + platformStyle.paddingMedium
            }
            PropertyChanges {
                target: sourceMulti
                height: Math.max(flickable.height - buttonRow.height
                                 - (inPortrait ? 3 : 2) * content.spacing,
                                 privateStyle.textFieldHeight)
            }
            PropertyChanges {
                target: languageSelectors
                visible: false
                height: 0
            }
            PropertyChanges {
                target: sourceExpandables
                visible: false
                height: 0
            }
            PropertyChanges {
                target: buttonRow
                visible: inPortrait ? true : false
                height: inPortrait ? implicitHeight : 0
            }
            PropertyChanges {
                target: bottom
                visible: false
                height: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "Active"
            reversible: true

            ParallelAnimation {
                ScriptAction {
                    script: {
                        flickable.contentY = 0;
                    }
                }
            }
        }
    ]

    Timer {
        id: noticePagePusher

        interval: 10
        onTriggered: {
            pageStack.push(privacyNoticePage);
        }
    }

    Component.onCompleted: {
        appWindow.platformInverted = translator.getSettingsValue("InvertedTheme", false);
        if (analytics_enabled && translator.privacyLevel == Translator.UndefinedPrivacy)
            noticePagePusher.start();
    }
}
