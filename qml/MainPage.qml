/*
 *  The Advanced Online Translator.
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
        anchors.fill: parent
        onClicked: {
            console.debug("CLICKED!!!");
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

    Column {
        id: col
        spacing: platformStyle.paddingMedium
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: platformStyle.paddingMedium
        }

        Row {
            width: parent.width

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
//            text: "Welcome"
            placeholderText: qsTr("Enter the source text...")
            focus: true

//            Keys.onReturnPressed: translator.translate();
//            Keys.onEnterPressed: translator.translate();

            onTextChanged: timer.restart();
        }
        TextArea {
            id: trans

            width: parent.width
            text: translator.translatedText
//            wrapMode: Text.WordWrap
            readOnly: true
        }
        Row {
            width: parent.width
            height: childrenRect.height
            spacing: platformStyle.paddingSmall
            visible: translator.detectedLanguage !== ""

            Label {
                font.weight: Font.Light
                text: qsTr("Detected language:")
            }
            Label {
                text: sourceLangs.getLangName(translator.detectedLanguage)
            }
        }
    }

    BusyIndicator {
        width: platformStyle.graphicSizeLarge
        height: width
        visible: translator.busy
        running: visible
        anchors {
            top: col.bottom
            topMargin: platformStyle.paddingLarge
            horizontalCenter: parent.horizontalCenter
        }
    }

    ScrollDecorator {
        flickableItem: listDictionary
    }

    ListView {
        id: listDictionary

        clip: true
        model: translator.dictionary
        spacing: platformStyle.paddingSmall
        interactive: count > 0
        cacheBuffer: 100 * platformStyle.paddingMedium
        anchors {
            top: col.bottom
            topMargin: platformStyle.paddingMedium
            left: parent.left
            leftMargin: platformStyle.paddingMedium
            bottom: parent.bottom
//            bottomMargin: platformStyle.paddingMedium
            right: parent.right
//            rightMargin: 0
        }

        delegate: MouseArea {
            width: ListView.view.width - platformStyle.paddingMedium
            height: posDelegate.height + indicator.height / 2

            onClicked: {
                ListView.view.focus = true;
                posDelegate.toggle();
            }

//            ListView.onAdd: NumberAnimation {
//                target: posDelegate
//                property: "opacity"
//                from: 0
//                to: 1
//                duration: 150
//                easing.type: Easing.Linear
//            }
//            ListView.onRemove: SequentialAnimation {
//                PropertyAction { target: posDelegate; property: "ListView.delayRemove"; value: true }
//                NumberAnimation {
//                    target: posDelegate
//                    property: "opacity"
//                    from: 1
//                    to: 0
//                    duration: 100
//                    easing.type: Easing.Linear
//                }
//                PropertyAction { target: posDelegate; property: "ListView.delayRemove"; value: false }
//            }

            Column {
                id: posDelegate

                property real maxWidth: 0

                width: parent.width
//                spacing: platformStyle.paddingSmall

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

        sourceText: source.text
//        service: "Yandex"

        onError: {
            console.debug(errorString);
            banner.text = errorString;
            banner.open();
        }
    }
}
