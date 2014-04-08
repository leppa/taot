import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import taot 1.0

ApplicationWindow {
    id: appWindow

    title: "TAO Translator"
    width: 800
    height: 600

    ScrollView {
        id: scrollView
        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
            right: parent.right
        }

        Item {
            width: scrollView.viewport.width
            height: top.height + 2 * top.spacing

            ColumnLayout {
                id: top

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: spacing
                }

                RowLayout {
                    Label {
                        text: qsTr("Translation service:")
                    }
                    ComboBox {
                        model: translator.services
                        textRole: "name"
                        currentIndex: translator.selectedService.index
                        Layout.fillWidth: true

                        onActivated: {
                            translator.selectService(index);
                        }
                    }
                }

                GridLayout {
                    columns: 6
                    Layout.fillWidth: true

                    Label {
                        text: qsTr("From:")
                    }
                    ComboBox {
                        property int sourceLanguageIndex: translator.sourceLanguages
                        .indexOf(translator.sourceLanguage)

                        model: translator.sourceLanguages
                        textRole: "name"
                        Layout.fillWidth: true

                        onActivated: {
                            translator.selectSourceLanguage(index);
                        }
                        onSourceLanguageIndexChanged: {
                            currentIndex = sourceLanguageIndex;
                        }
                    }

                    Button {
                        id: swap

                        iconName: "document-swap"
                        iconSource: Qt.resolvedUrl("icons/document-swap.svgz")
                        enabled: translator.canSwapLanguages
                        Layout.preferredWidth: height
                        Layout.columnSpan: 2

                        onClicked: {
                            translator.swapLanguages();
                        }
                    }

                    Label {
                        text: qsTr("To:")
                    }
                    ComboBox {
                        property int targetLanguageIndex: translator.targetLanguages
                        .indexOf(translator.targetLanguage)

                        model: translator.targetLanguages
                        textRole: "name"
                        Layout.fillWidth: true

                        onActivated: {
                            translator.selectTargetLanguage(index);
                        }
                        onTargetLanguageIndexChanged: {
                            currentIndex = targetLanguageIndex;
                        }
                    }

                    TextArea {
                        id: source

                        text: "Welcome"
                        textFormat: TextEdit.PlainText
                        wrapMode: TextEdit.Wrap
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        Layout.fillHeight:true

                        onTextChanged: {
                            if (translator.sourceText == text)
                                return;

                            translator.sourceText = text;
                        }
                        onActiveFocusChanged: {
                            if (activeFocus)
                                textAreaContextMenu.focusedArea = source;
                            else if (textAreaContextMenu.focusedArea == source)
                                textAreaContextMenu.focusedArea = null;
                        }

//                        MouseArea {
//                            acceptedButtons: Qt.RightButton
//                            cursorShape: Qt.IBeamCursor
//                            anchors.fill: parent
//                            onClicked: {
//                                textAreaContextMenu.focusedArea = source;
//                                textAreaContextMenu.popup();
//                            }
//                        }
                    }
                    TextArea {
                        id: target

                        height: translator.supportsTranslation ? implicitHeight : 0
                        text: translator.translatedText
                        textFormat: Text.PlainText
                        readOnly: true
                        wrapMode: TextEdit.Wrap
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        Layout.fillHeight:true

                        Behavior on height {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }
                        }

                        onActiveFocusChanged: {
                            if (activeFocus)
                                textAreaContextMenu.focusedArea = target;
                            else if (textAreaContextMenu.focusedArea == target)
                                textAreaContextMenu.focusedArea = null;
                        }
                    }

                    Button {
                        width: (parent.width - parent.spacing) / 2
                        text: qsTr("Translate")
                        enabled: !translator.busy
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        onClicked: {
                            translator.translate();
                        }

                        BusyIndicator {
                            height: parent.height
                            visible: translator.busy
                            running: visible
                            anchors.centerIn: parent
                        }
                    }
                    Button {
                        width: (parent.width - parent.spacing) / 2
                        text: qsTr("Clear")
                        enabled: source.text != ""
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        onClicked: {
                            source.text = "";
                            source.forceActiveFocus();
                        }
                    }

                    Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }}
                }

                RowLayout {
                    id: detectedLanguage

                    state: "Empty"
                    clip: true

                    Label {
                        text: qsTr("Detected language:")
                    }
                    Label {
                        id: dl
                        font.weight: Font.Bold
                        text: translator.detectedLanguageName
                    }

                    states: [
                        State {
                            name: "Empty"
                            when: translator.detectedLanguageName === ""

                            PropertyChanges {
                                target: detectedLanguage
                                opacity: 0
                                scale: 0
                                Layout.preferredHeight: 0
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

                            SequentialAnimation {
                                NumberAnimation {
                                    target: detectedLanguage
                                    property: "Layout.preferredHeight"
                                    duration: 300
                                    easing.type: Easing.OutBack
                                }
                                PropertyAction {
                                    targets: [detectedLanguage,dl]
                                    properties: "scale,opacity,text"
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
                    id: listDictionary

                    clip: true
                    model: translator.dictionary

                    delegate: DictionaryDelegate {}
                }
            }
        }
    }

    menuBar: MenuBar {
        id: mainMenu

        Menu {
            title: qsTr("File")

            MenuItem {
                text: qsTr("Exit")
                onTriggered: Qt.quit();
            }
        }

        Menu {
            id: textAreaContextMenu
            title: qsTr("Edit")
            enabled: focusedArea

            property TextArea focusedArea

            MenuItem {
                text: qsTr("Undo")
                iconName: "edit-undo"
                enabled: textAreaContextMenu.focusedArea
                         && textAreaContextMenu.focusedArea.canUndo
                         && !textAreaContextMenu.focusedArea.readOnly
                onTriggered: textAreaContextMenu.focusedArea.undo()
            }
            MenuSeparator {}
            MenuItem {
                text: qsTr("Cut")
                iconName: "edit-cut"
                enabled: textAreaContextMenu.focusedArea
                         && textAreaContextMenu.focusedArea.selectionStart
                            != textAreaContextMenu.focusedArea.selectionEnd
                         && !textAreaContextMenu.focusedArea.readOnly
                onTriggered: textAreaContextMenu.focusedArea.cut()
            }
            MenuItem {
                text: qsTr("Copy")
                iconName: "edit-copy"
                enabled: textAreaContextMenu.focusedArea
                         && textAreaContextMenu.focusedArea.selectionStart
                            != textAreaContextMenu.focusedArea.selectionEnd
                onTriggered: textAreaContextMenu.focusedArea.copy()
            }
            MenuItem {
                text: qsTr("Paste")
                iconName: "edit-paste"
                enabled: textAreaContextMenu.focusedArea
                         && !textAreaContextMenu.focusedArea.readOnly
                onTriggered: textAreaContextMenu.focusedArea.paste()
                             && !textAreaContextMenu.focusedArea.readOnly
            }
            MenuSeparator {}
            MenuItem {
                text: qsTr("Select All")
                iconName: "edit-select-all"
                enabled: textAreaContextMenu.focusedArea
                         && textAreaContextMenu.focusedArea.text != ""
                onTriggered: textAreaContextMenu.focusedArea.selectAll()
            }
        }

        Menu {
            title: qsTr("Help")

            MenuItem {
                text: qsTr("Check for Update...")
//                onClicked: {
//                    pageStack.push(updateCheckerPageComponent);
//                }
            }
            MenuSeparator {}
            MenuItem {
                iconName: "help-about"
                text: qsTr("About")
//                onClicked: pageStack.push(aboutPageComponent);
            }
        }
    }

    Translator {
        id: translator

        onError: {
            console.debug(errorString);
            message.text = errorString;
            message.open();
        }
    }

    MessageDialog {
        id: message

        title: qsTr("Translation Error")
        icon: StandardIcon.Critical
    }

//    Component {
//        id: aboutPageComponent

//        AboutPage {}
//    }

//    Component {
//        id: updateCheckerPageComponent
//        UpdateCheckerPage {}
//    }
}
