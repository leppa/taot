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

#ifndef CLIPBOARD_H
#define CLIPBOARD_H

#include <QObject>
#include <QClipboard>

class Clipboard: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString text READ text WRITE insert NOTIFY textChanged)
    Q_PROPERTY(bool empty READ isEmpty NOTIFY textChanged)

public:
    explicit Clipboard(QObject *parent = 0);
    bool isEmpty() const;

public slots:
    void clear();
    QString text() const;
    void insert(const QString &text);

signals:
    void textChanged();

private slots:
    void onChanged(QClipboard::Mode mode = QClipboard::Clipboard);

private:
    QString m_text;
};

#endif // CLIPBOARD_H
