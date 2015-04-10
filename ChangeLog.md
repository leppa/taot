TAO Translator ChangeLog
========================


TAOT v1.1.0
-----------

- Fixed Google Translate service ([issue #36]).
- It is now possible to swap source and translation languages when
  source language is set to autodetect and language was successfully
  autodetected.
- Support for changing interface language ([issue #29][]).
- Clear button is now an icon.
- All settings were moved to a new Settings page.
- "Send Feedback" option was added. This will open an e-mail composer
  with pre-filled subject and recipient.
- Parts of text on the About page were made localizable.
- Source and target translation languages were updated for all services.
- Google Translate: Support for articles in the dictionary (provided
  only for some languages, like German).
- BlackBerry 10: TAO Translator is now a share target: select text in
  any application, press "Share" icon and select TAO Translator from the
  list. The text will be opened for translation in TAO Translator.
- BlackBerry 10: Source / target language selection dropdowns now expand
  to full width when opened.
- BlackBerry 10: Support for switching between Dark and Bright / Light
  themes ([issue #33][]).
- BlackBerry 10: A possibility to share translation through the standard
  share menu.
- BlackBerry 10: Fixed badly readable text in the title (white text on
  light background) in BlackBerry OS 10.3.
- BlackBerry 10: Fixed empty active frame when TAO Translator is started
  with dark theme ([issue #35][]).
- Symbian, Nokia N9: Workaround for a bug when virtual keyboard in some
  cases covers text input ([issue #32][]).
- New UI localization: Czech.


TAOT v1.0.1
-----------

- Google Translate: updated list of available translation languages.
- Made icon background a bit smoother.
- New UI localization: Danish.
- German UI localization was updated.
- Sailfish: translation result text is now read only.
- Nokia N9: fixed old icon was shown in Settings -> Applications ->
  Manage applications.


TAOT v1.0.0
-----------

- Renamed application into TAO Translator.
- New application icon ([issue #16][]).
- New UI localizations: German and Italian.
- BlackBerry 10: completely rewritten UI in Cascades ([issue #9][]).
- Nokia N9, Symbian: Added update checker functionality ([issue #23][]).


TAOT v0.3.2.1
-------------

- Sailfish OS: fixed settings file path to comply with Harbour rules.


TAOT v0.3.2
-----------

- Moved busy indicator on top of Translate button.
- Shortened icon label to TAO Translator.
- Updated copyright years.
- Localization: Chinese, Dutch and Turkish translations.
- Sailfish OS: enabled landscape and inverted landscape orientations
  ([issue #22][]).
- Sailfish OS: added display of source and translated text to the cover
  ([issue #21][]).
- Nokia N9, Symbian: Removed notice about Nokia Store freeze.


TAOT v0.3.1
-----------

- Sailfish OS port ([issue #6][]).
- Yandex.Dictionaries: added display of synonyms.
- About dialog was converted to a page. Links were added to the text.
- Symbian, BlackBerry 10: Translate and Clear buttons are no longer
  hidden when source text is empty.


TAOT v0.3.0
-----------

- Added Yandex.Dictionaries translation service ([issue #12][]).
- Localization: added Ukrainian and Russian translations
  ([issue #11][]).


TAOT v0.2.1
-----------

- Support for language swap ([issue #13][]).
- Yandex.Translate: Fixed SSL handshake error due to a missing CA
  certificate.
- Yandex.Translate: Added error handling.
- Yandex.Translate: Sort languages by name ([issue #14][]).


TAOT v0.2.0
-----------

- New translation services:
  * Microsoft Translator (a.k.a. Bing Translator) ([issue #7][]).
  * Yandex.Translate ([issue #8][]).
- Inverted theme support ([issue #10][]).
- Removed autotranslation on source text change.
- Some bugfixes.


TAOT v0.1.4
-----------

- Nokia N9 port ([issue #4][]).
- Re-run translation if source or target language was changed.


TAOT v0.1.3
-----------

- Symbian port ([issue #5][]).
- Small layout changes:
  * Moved Translate button below the source text: it is now visible even
    when virtual keyboard is shown.
  * Added Clear button to be able to quickly clear the input field.


TAOT v0.1.2
-----------

- Landscape orientation support for BlackBerry Z10 and Z30
  ([issue #2][]).
- Support for square resolution of BlackBerry Q5 and Q10 ([issue #3][]).
- Few UI improvements.
- Fix: Translation doesn't fit on the screen when translating large
  texts ([issue #1][]).


TAOT v0.1.1
-----------

- Support for multiline text translation.
- Automatic translation of current text when no typing for 1.5 seconds.
- About dialog with version and copyright information.
- Some eye candy :-)
- Bugfixes.


TAOT v0.1.0
-----------

Initial release.


[issue #1]: https://github.com/leppa/taot/issues/1
[issue #2]: https://github.com/leppa/taot/issues/2
[issue #3]: https://github.com/leppa/taot/issues/3
[issue #4]: https://github.com/leppa/taot/issues/4
[issue #5]: https://github.com/leppa/taot/issues/5
[issue #6]: https://github.com/leppa/taot/issues/6
[issue #7]: https://github.com/leppa/taot/issues/7
[issue #8]: https://github.com/leppa/taot/issues/8
[issue #9]: https://github.com/leppa/taot/issues/9
[issue #10]: https://github.com/leppa/taot/issues/10
[issue #11]: https://github.com/leppa/taot/issues/11
[issue #12]: https://github.com/leppa/taot/issues/12
[issue #13]: https://github.com/leppa/taot/issues/13
[issue #14]: https://github.com/leppa/taot/issues/14
[issue #16]: https://github.com/leppa/taot/issues/16
[issue #21]: https://github.com/leppa/taot/issues/21
[issue #22]: https://github.com/leppa/taot/issues/22
[issue #23]: https://github.com/leppa/taot/issues/23
[issue #29]: https://github.com/leppa/taot/issues/29
[issue #32]: https://github.com/leppa/taot/issues/32
[issue #33]: https://github.com/leppa/taot/issues/33
[issue #35]: https://github.com/leppa/taot/issues/35
[issue #36]: https://github.com/leppa/taot/issues/36

<!-- $Id: $Format:%h %ai %an$ $ -->
