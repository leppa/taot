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

    XmlListModel {
        id: sourceLangs

        function getLangName(code)
        {
            for (var k = 0; k < count; k++)
                if (get(k).code === code)
                    return get(k).name;
            return qsTr("Unknown")
        }

        function getLangIndex(code)
        {
            for (var k = 0; k < count; k++)
                if (get(k).code === code)
                    return k;
            return -1
        }

        source: Qt.resolvedUrl("langs.xml")
        query: "/LanguagePairs/Pair"
        onQueryChanged: reload();

        XmlRole { name: "name"; query: "@source_name/string()" }
        XmlRole { name: "code"; query: "@source_id/string()" }
    }

    XmlListModel {
        id: targetLangs

        function getLangName(code)
        {
            for (var k = 0; k < count; k++)
                if (get(k).code === code)
                    return get(k).name;
            return qsTr("Unknown")
        }

        function getLangIndex(code)
        {
            for (var k = 0; k < count; k++)
                if (get(k).code === code)
                    return k;
            return -1
        }

        source: Qt.resolvedUrl("langs.xml")
        query: "/LanguagePairs/Pair[not(@source_id='auto')]"
        onQueryChanged: reload();

        XmlRole { name: "name"; query: "@source_name/string()" }
        XmlRole { name: "code"; query: "@source_id/string()" }
    }

    SelectionDialog {
        id: fromDialog
        titleText: qsTr("Select the source language")
        selectedIndex: 0
        model: sourceLangs
        delegate: MenuItem {
            text: model.name
            privateSelectionIndicator: selectedIndex == index
            onClicked: {
                selectedIndex = index;
                translator.sourceLanguage = model.code;
                fromDialog.accept();
            }
        }
    }

    SelectionDialog {
        id: toDialog
        titleText: qsTr("Select the target language")
        selectedIndex: 0
        model: targetLangs
        delegate: MenuItem {
            text: model.name
            privateSelectionIndicator: selectedIndex == index
            onClicked: {
                selectedIndex = index;
                translator.targetLanguage = model.code;
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
                height: childrenRect.height

                SelectionListItem {
                    width: parent.width / 2
                    title: qsTr("From");
                    subTitle: sourceLangs.getLangName(translator.sourceLanguage);

                    onClicked: {
                        fromDialog.selectedIndex = sourceLangs.getLangIndex(translator.sourceLanguage);
                        fromDialog.open();
                    }
                }
                SelectionListItem {
                    width: parent.width / 2
                    title: qsTr("To")
                    subTitle: targetLangs.getLangName(translator.targetLanguage)

                    onClicked: {
                        toDialog.selectedIndex = targetLangs.getLangIndex(translator.targetLanguage);
                        toDialog.open();
                    }
                }
            }

            Timer {
                id: timer
                interval: 1500

                onTriggered: {
                    if (source.text !== "")
                        translator.translate();
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
                    translator.sourceText = text;
                    timer.restart();
                }
            }

            BorderImage {
                height: trans.height + 2 * platformStyle.borderSizeMedium
                source: privateStyle.imagePath("qtg_fr_textfield_uneditable", false)
                smooth: true
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
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: platformStyle.borderSizeMedium
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
                }
                Label {
                    id: dl
                    text: sourceLangs.getLangName(translator.detectedLanguage)
                }

                states: [
                    State {
                        name: "Empty"
                        when: translator.detectedLanguage === ""

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

    BusyIndicator {
        width: platformStyle.graphicSizeLarge
        height: width
        z: 100
        visible: translator.busy
        running: visible
        anchors.centerIn: parent
    }

    ScrollDecorator {
        flickableItem: listDictionary
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
            fill: parent
            margins: platformStyle.paddingMedium
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

    tools: ToolBarLayout {
        ToolButton {
            iconSource: Qt.resolvedUrl("icons/close.svg")
            onClicked: Qt.quit();
        }
        ToolButton {
            text: qsTr("Translate")
            onClicked: translator.translate();
        }
        ToolButton {
            iconSource: "toolbar-menu"
            onClicked: mainMenu.open();
        }
    }

    Menu {
        id: mainMenu

        MenuLayout {
            MenuItem {
                text: qsTr("About")
                onClicked: aboutDialog.open();
            }
        }
    }

    QueryDialog {
        id: aboutDialog

        titleText: "<b>The Advanced Online Translator</b> v%1".arg(translator.version)
        acceptButtonText: qsTr("Ok")
        privateCloseIcon: true

        message: "<p>Copyright &copy; 2013 <b>Oleksii Serdiuk</b> &lt;contacts[at]oleksii[dot]name&gt;</p>
<p>&nbsp;</p>
<p>The Advanced Online Translator uses available online translation
services to provide translations. Currently it supports only Google
Translate but more services are in the plans (i.e., Bing Translate,
Yandex Translate, etc.).</p>

<p>For Google Translate alternative and reverse translations are displayed
for single words.</p>
<p>&nbsp;</p>
<p>This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.</p>

<p>This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.</p>

<p>You should have received a copy of the GNU General Public License
along with this program.  If not, see &lt;http://www.gnu.org/licenses/&gt;.</p>"
    }

    Translator {
        id: translator

//        service: "Yandex"

        onError: {
            console.debug(errorString);
            banner.text = errorString;
            banner.open();
        }
    }

    Component {
        id: translationPage
        TranslationTextAreaPage {}
    }
}
