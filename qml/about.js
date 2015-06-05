/*
 *  TAO Translator
 *  Copyright (C) 2013-2015  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
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

// TODO: Clean up this mess!
var aboutText =
"<p><a href=\"https://github.com/leppa/taot\">https://github.com/leppa/taot</a></p> " +
"<p>Copyright &copy; 2013-2015 <a href=\"&#109;&#097;&#105;&#108;&#116;&#111;:&#099;&#111;&#110;&#116;&#097;&#099;&#116;&#115;&#064;&#111;&#108;&#101;&#107;&#115;&#105;&#105;&#046;&#110;&#097;&#109;&#101;?subject=TAO%20Translator\">Oleksii Serdiuk</a></p> " +
"<p>&nbsp;</p> " +
"<p>" + qsTr("%1 is free software that I develop in my spare time. If you like it, I would appreciate a donation: <a href=\"%2\">Donate</a>.").arg("TAO Translator").arg("https://github.com/leppa/taot/wiki/Donate") + "</p> " +
"<p>&nbsp;</p> " +
"<p>" +
qsTr("%1 contains the following contributed translations:").arg("TAO Translator") + " " +
"<b>Chinese</b> by gwmgdemj and 太空飞瓜 (finalmix), " +
"<b>Dutch</b> by teunwinters and Heimen Stoffels (Vistaus), " +
"<b>German</b> by buschmann and DeadHorseRiding (Mee_Germany_Go), " +
"<b>Italian</b> by Francesco Vaccaro (ghostofasmile) and Alessandro Pra' (Watchmaker), " +
"<b>Turkish</b> by Mehmet Ç. (fnldstntn), " +
"<b>Danish</b> by Peter Jespersen (flywheeldk), " +
"<b>Chech</b> by Jakub Kožíšek (nodevel), " +
"<b>Greek</b>, by Wasilis Mandratzis-Walz (beonex)." +
"</p> " +
"<p>&nbsp;</p> " +
"<p>" + qsTr("If your language is missing, you can <a href=\"%2\">help translating %1 into your language</a>.").arg("TAO Translator").arg("https://www.transifex.com/projects/p/taot/") + "</p> " +
"<p>&nbsp;</p> " +
qsTr("<p>%1 uses online translation services to provide translations.</p>" +
     "<p>Currently supported services:</p>" +
     "<ul>" +
     "\t<li><b>Google Translate</b> - supports translation, language detection, dictionary and reverse translations for single words.</li>\n" +
     "\t<li><b>Microsoft Translator</b> (a.k.a. <b>Bing Translator</b>) - supports translation only.</li>\n" +
     "\t<li><b>Yandex.Translate</b> - supports translation and language detection.</li>\n" +
     "\t<li><b>Yandex.Dictionaries</b> - supports dictionary with synonyms and reverse translations.</li>\n" +
     "</ul>" +
     "<p>More services are possible in future.</p>").arg("TAO Translator") + " " +
"<p>&nbsp;</p> " +
"<p>This program is free software; you can redistribute it and/or " +
"modify it under the terms of the GNU General Public License " +
"as published by the Free Software Foundation; either version 2 " +
"of the License, or (at your option) any later version.</p> " +
"<p>This program is distributed in the hope that it will be useful, " +
"but WITHOUT ANY WARRANTY; without even the implied warranty of " +
"MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the " +
"GNU General Public License for more details.</p> " +
"<p>You should have received a copy of the GNU General Public License " +
"along with this program.  If not, see &lt;<a href=\"http://www.gnu.org/licenses/\">http://www.gnu.org/licenses/</a>&gt;.</p>"
