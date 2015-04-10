/*
 * Copyright (c) 2011-2013 BlackBerry Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "languagechangelistener.h"

#include <QTranslator>
#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>
#include <bb/cascades/LocaleHandler>

LanguageChangeListener::LanguageChangeListener(QObject *parent)
    : QObject(parent)
{
    m_pLocaleHandler = new bb::cascades::LocaleHandler(this);
    connect(m_pLocaleHandler, SIGNAL(systemLanguageChanged()), SLOT(onSystemLanguageChanged()));

    onSystemLanguageChanged();
}

void LanguageChangeListener::onSystemLanguageChanged()
{
    static QTranslator *qtTr = NULL;
    if (qtTr) {
        qApp->removeTranslator(qtTr);
        delete qtTr;
    }

    static QTranslator *tr = NULL;
    if (tr) {
        qApp->removeTranslator(tr);
        delete tr;
    }

    QString lc = QLocale().name();
    QSettings settings(QCoreApplication::organizationName(), "taot");
    if (settings.contains("UILanguage")) {
        const QString lang = settings.value("UILanguage").toString();
        if (!lang.isEmpty())
            lc = lang;
    }

    // Load Qt's translation
    qtTr = new QTranslator(this);
    if (qtTr->load("qt_" + lc, QLibraryInfo::location(QLibraryInfo::TranslationsPath)))
        qApp->installTranslator(qtTr);

    // Load TAOT's translation
    tr = new QTranslator(this);
    if (tr->load("taot_" + lc, ":/l10n"))
        qApp->installTranslator(tr);
}
