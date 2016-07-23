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

import bb.cascades 1.0
import bb.system 1.0

Page {
    titleBar: TitleBar {
        title: qsTr("Donation FAQ")
    }
    ScrollView {
        Container {
            property int padding: 20

            topPadding: padding
            leftPadding: padding
            bottomPadding: padding
            rightPadding: padding

            FaqItem {
                q: qsTr("Why do you ask for donations?")
                a: qsTr("I'm developing %1 in my spare time and provide it completely for free."
                        + " Moreover, %1 is Open Source. Receiving donations will encourage me to"
                        + " continue developing and supporting %1. It will also show that my work"
                        + " is appreciated.").arg("TAO Translator")
            }
            FaqItem {
                q: qsTr("Am I required to donate to use %1?").arg("TAO Translator")
                a: qsTr("Absolutely not. %1 is free and Open Source. You're not required to make"
                        + " any donations to use it. However, this way you can show your support.")
                   .arg("TAO Translator")
            }
            FaqItem {
                q: qsTr("What are those coins?")
                a: qsTr("I'm using BlackBerry Payment Service to accept donations and BlackBerry"
                        + " takes 30% commission from each payment. For example, if you donate"
                        + " 4.99$ (34 coins), I will get about 3.49$. So each coin roughly"
                        + " corresponds to 0.10$ that I will get.")
            }
            FaqItem {
                q: qsTr("Do I get something for making a donation?")
                a: qsTr("You already have %1. Completely for free :-)\n"
                        + "However, if it's not enough, the amount of your donation along with"
                        + " \"Thank you!\" message will be displayed at the top of the About page.")
                   .arg("TAO Translator")
            }
            FaqItem {
                q: qsTr("I want to increase my donation. Is it possible?")
                a: qsTr("Just make a new one. You can make as many donations as you want. They will"
                        + " accumulate and total amount will be displayed on the About page.");
            }
            FaqItem {
                q: qsTr("I changed my mind and want to get my donation back!")
                a: qsTr("Very sorry to hear that. I'm not managing any payments, so you'll have to"
                        + " contact <a href=\"%1\">BlackBerry World support</a> to request a"
                        + " refund.").arg("http://www.blackberry.com/support/appworld");
            }
            FaqItem {
                q: qsTr("I don't want to pay in-app. Are there any other ways to donate?")
                a: qsTr("Yes, there is <em>Donate</em> link on the About page. Tap it and you will"
                        + " be taken to a web page where you can donate with PayPal, Flattr, or"
                        + " WebMoney.")
            }
            FaqItem {
                q: qsTr("My question isn't answered. How can I get in touch?")
                a: qsTr("Write me an e-mail. Just swipe from the top and tap <em>Send feedback</em>"
                        + " in the menu. An e-mail will open with my address pre-filled.")
            }
        }
    }
}
