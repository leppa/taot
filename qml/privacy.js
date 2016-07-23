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

.pragma library

var notice = qsTranslate("PrivacyNoticePage",
                         "Would you like to help improve %1 by enabling application analytics?")
                        .arg("TAO Translator");

var noPrivacyText = qsTranslate("PrivacyNoticePage", "Yes, enable full analytics");
var errorsOnlyText = qsTranslate("PrivacyNoticePage", "Enable only error reporting");
var maxPrivacyText = qsTranslate("PrivacyNoticePage", "No, I don't want to help");

var details =
qsTranslate("PrivacyNoticePage",
            "<p>%1 contains application analytics functionality that can collect information about"
            + " actions performed in the application, application errors, and some information"
            + " about your device. This information is processed by a third party analytics"
            + " service, <a href=\"%3\">Amplitude Analytics</a>. No personally identifiable"
            + " information is sent. Collected information will be used solely for the purpose of"
            + " improving %1, fixing errors, and analysing application usage.</p>\n"
            + "<p>Please read <a href=\"%2\">%1 Privacy Policy</a> for full information about what"
            + " data is sent and when. You can also consult End User Information section of <a"
            + " href=\"%4\">Amplitude Analytics Privacy Policy</a> to see how they deal with the"
            + " data that we send to them.</p>")
.arg("TAO Translator")
.arg("https://github.com/leppa/taot/wiki/Privacy-Policy")
.arg("https://amplitude.com/")
.arg("https://amplitude.com/privacy");
