/****************************************************************************
**
** Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the Qt Components project.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Nokia Corporation and its Subsidiary(-ies) nor
**     the names of its contributors may be used to endorse or promote
**     products derived from this software without specific prior written
**     permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 1.1
import com.nokia.symbian 1.1

Item {
    id: root

    property alias text: textArea.text

    // Symbian specific API
    property bool platformInverted: false
    property bool platformSubItemIndicator: false
    property real platformLeftMargin: platformStyle.paddingLarge

    property bool privateSelectionIndicator: false

    signal clicked

    width: parent.width; height: privateStyle.menuItemHeight

    QtObject {
        id: internal

        function bg_postfix() {
            if (activeFocus && symbian.listInteractionMode == Symbian.KeyNavigation)
                return "highlighted"
            else if (mouseArea.pressed && mouseArea.containsMouse && !mouseArea.canceled)
                return "pressed"
            else
                return "popup_normal"
        }

        function textColor() {
            if (!enabled)
                return root.platformInverted ? platformStyle.colorDisabledLightInverted
                                             : platformStyle.colorDisabledLight
            else if (activeFocus && symbian.listInteractionMode == Symbian.KeyNavigation)
                return root.platformInverted ? platformStyle.colorHighlightedInverted
                                             : platformStyle.colorHighlighted
            else if (mouseArea.pressed && mouseArea.containsMouse)
                return root.platformInverted ? platformStyle.colorPressedInverted
                                             : platformStyle.colorPressed
            else
                return root.platformInverted ? platformStyle.colorNormalLightInverted
                                             : platformStyle.colorNormalLight
        }
    }

    BorderImage {
        source: privateStyle.imagePath("qtg_fr_list_" + internal.bg_postfix(), root.platformInverted)
        border { left: 20; top: 20; right: 20; bottom: 20 }
        anchors.fill: parent
    }

    Text {
        id: textArea
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: platformLeftMargin
            right: iconLoader.status == Loader.Ready ? iconLoader.left : parent.right
            rightMargin: iconLoader.status == Loader.Ready ? platformStyle.paddingMedium : privateStyle.scrollBarThickness
        }
        font { family: platformStyle.fontFamilyRegular; pixelSize: platformStyle.fontSizeLarge }
        color: internal.textColor()
        horizontalAlignment: Text.AlignLeft
        elide: Text.ElideRight
    }

    Loader {
        id: iconLoader
        sourceComponent: (root.platformSubItemIndicator || root.privateSelectionIndicator) ? iconComponent : undefined
        anchors {
            right: parent.right
            rightMargin: privateStyle.scrollBarThickness
            verticalCenter: parent.verticalCenter
        }
    }

    Component {
        id: iconComponent

        Image {
            source: {
                if (root.privateSelectionIndicator)
                    privateStyle.imagePath("qtg_graf_single_selection_indicator", platformInverted)
                else
                    privateStyle.imagePath("qtg_graf_drill_down_indicator", platformInverted)
            }
            sourceSize.width: platformStyle.graphicSizeSmall
            sourceSize.height: platformStyle.graphicSizeSmall
            mirror: LayoutMirroring.enabled
        }
    }


    MouseArea {
        id: mouseArea

        property bool canceled: false

        anchors.fill: parent

        onPressed: {
            canceled = false
            symbian.listInteractionMode = Symbian.TouchInteraction
            privateStyle.play(Symbian.BasicItem)
        }
        onClicked: {
            if (!canceled)
                root.clicked()
        }
        onReleased: {
            if (!canceled)
                privateStyle.play(Symbian.BasicItem)
        }
        onExited: canceled = true
    }

    Keys.onPressed: {
        event.accepted = true
        switch (event.key) {
            case Qt.Key_Select:
            case Qt.Key_Enter:
            case Qt.Key_Return:
                if (!event.isAutoRepeat) {
                    if (symbian.listInteractionMode != Symbian.KeyNavigation)
                        symbian.listInteractionMode = Symbian.KeyNavigation
                    else
                        root.clicked()
                }
                break

            case Qt.Key_Up:
                if (symbian.listInteractionMode != Symbian.KeyNavigation) {
                    symbian.listInteractionMode = Symbian.KeyNavigation
                    if (ListView.view)
                        ListView.view.positionViewAtIndex(index, ListView.Beginning)
                } else {
                    if (ListView.view)
                        ListView.view.decrementCurrentIndex()
                    else
                        event.accepted = false
                }
                break

            case Qt.Key_Down:
                if (symbian.listInteractionMode != Symbian.KeyNavigation) {
                    symbian.listInteractionMode = Symbian.KeyNavigation
                    if (ListView.view)
                        ListView.view.positionViewAtIndex(index, ListView.Beginning)
                } else {
                    if (ListView.view)
                        ListView.view.incrementCurrentIndex()
                    else
                        event.accepted = false
                }
                break
            case Qt.Key_Left:
            case Qt.Key_Right:
                // If this MenuItem belongs to Menu invoke highlight
                // in other cases consume event but do nothing
                if (!ListView.view && symbian.listInteractionMode != Symbian.KeyNavigation)
                    symbian.listInteractionMode = Symbian.KeyNavigation
                break
            default:
                event.accepted = false
                break
        }
    }
}
