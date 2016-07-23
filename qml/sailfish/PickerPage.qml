/*
 *  TAO Translator
 *  Copyright (C) 2013-2016  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
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
    id: root

    property string title
    property alias model: listView.model
    property alias currentIndex: listView.currentIndex

    signal selected(int index)

    allowedOrientations: Orientation.Portrait
                         | Orientation.Landscape
                         | Orientation.LandscapeInverted

    SilicaListView {
        id: listView
        anchors.fill: parent

        header: PageHeader {
            title: root.title
        }

        delegate: BackgroundItem {
            id: delegate

            Label {
                x: Theme.paddingLarge
                text: model.name
                color: delegate.highlighted
                       || delegate.ListView.isCurrentItem ? Theme.highlightColor
                                                          : Theme.primaryColor
                anchors.verticalCenter: parent.verticalCenter
            }

            onClicked: {
                root.selected(model.index);
            }
        }
        VerticalScrollDecorator {}
    }
}
