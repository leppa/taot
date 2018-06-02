/*
 *  TAO Translator
 *  Copyright (C) 2013-2018  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
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

#include "clipboard.h"

#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
#   include <QApplication>
#else
#   include <QGuiApplication>
#endif

#include <QDebug>

Clipboard::Clipboard(QObject *parent)
    : QObject(parent)
    , m_text(qApp->clipboard()->text())
{
    connect(qApp->clipboard(), SIGNAL(changed(QClipboard::Mode)),
            this, SLOT(onChanged(QClipboard::Mode)));
}

bool Clipboard::isEmpty() const
{
    return m_text.isEmpty();
}

void Clipboard::clear()
{
    qApp->clipboard()->clear();
}

QString Clipboard::text() const
{
    return m_text;
}

void Clipboard::insert(const QString &text)
{
    qApp->clipboard()->setText(text);
}

void Clipboard::onChanged(QClipboard::Mode mode)
{
    const QString text = qApp->clipboard()->text();
    if (mode != QClipboard::Clipboard || m_text == text)
        return;

    m_text = text;
    emit textChanged();
}
