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

import bb.cascades 1.0
import "about.js" as About

Page {
    id: root

    titleBar: TitleBar {
        title: "TAO Translator"
    }
    ScrollView {
        Container {
            property int padding: 20

            topPadding: padding
            leftPadding: padding
            bottomPadding: padding
            rightPadding: padding

            Label {
                text: qsTr("Version: <b>%1</b>").arg(translator.version)
                textStyle.base: SystemDefaults.TextStyles.PrimaryText
                textFormat: TextFormat.Html
            }
            Label {
                text: qsTr("You donated <b>%n coins</b>. Thank you!",
                           "",
                           donationManager.totalCoinCount)
                textFormat: TextFormat.Html
                multiline: true
                visible: donationManager.totalCoinCount > 0
            }
            Label {
                multiline: true
                text: About.aboutText
                textFormat: TextFormat.Html
            }
        }
    }
}
