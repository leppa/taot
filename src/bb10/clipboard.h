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
#include <QMetaType>

class QFileSystemWatcher;
namespace bb { namespace system { class Clipboard; } }
class Clipboard: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString text READ text WRITE insert NOTIFY textChanged)
    Q_PROPERTY(bool empty READ isEmpty NOTIFY textChanged)

public:
    explicit Clipboard(QObject *parent = 0);
    bool isEmpty() const;

public slots:
    bool clear();
    QString text() const;
    bool insert(const QString &text);

signals:
    void textChanged();

private slots:
    void onDirectoryChanged(const QString &path);
    void onFileChanged(const QString &path);

private:
    bb::system::Clipboard *m_clipboard;
    QString m_text;
    QFileSystemWatcher *m_clipboardWatcher;

    void addClipboardFileWatcher();
    void updateClipboardText();
};

Q_DECLARE_METATYPE(Clipboard *)

#endif // CLIPBOARD_H
