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

Container {
    topPadding: 5
    leftPadding: 10
    bottomPadding: 5
    rightPadding: 10
    background: Application.themeSupport.theme.colorTheme.style === VisualStyle.Dark
                ? Color.Black
                : Color.White
    Container {
        layoutProperties: StackLayoutProperties { spaceQuota: 0.5 }
        Label {
            text: qsTr("From: <b>%1</b>").arg(translator.sourceLanguage.displayName)
                  + Retranslate.onLocaleOrLanguageChanged
            bottomMargin: 0
            textFormat: TextFormat.Html
            textStyle {
                fontSize: FontSize.XXSmall
            }
        }
        Label {
            text: translator.sourceText
            topMargin: 0
            bottomMargin: 0
            multiline: true
            textFormat: TextFormat.Plain
            textStyle {
                fontSize: FontSize.XSmall
            }
        }
    }
    Divider {
        topMargin: 5
        bottomMargin: 5
    }
    Container {
        layoutProperties: StackLayoutProperties { spaceQuota: 0.5 }
        Label {
            text: qsTr("To: <b>%1</b>").arg(translator.targetLanguage.displayName)
                  + Retranslate.onLocaleOrLanguageChanged
            bottomMargin: 0
            textFormat: TextFormat.Html
            textStyle {
                fontSize: FontSize.XXSmall
            }
        }
        Label {
            text: translator.translatedText
            topMargin: 0
            multiline: true
            textFormat: TextFormat.Plain
            textStyle {
                fontSize: FontSize.XSmall
            }
        }
    }
}
