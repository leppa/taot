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

#include "symbianapplication.h"

#include <QSymbianEvent>
#include <w32std.h>
#include <QDebug>

SymbianApplication::SymbianApplication(int &argc, char **argv)
    : QApplication(argc, argv), m_visibility(NotVisible)
{}

SymbianApplication::Visibility SymbianApplication::visibility() const
{
    return m_visibility;
}

bool SymbianApplication::symbianEventFilter(const QSymbianEvent *event)
{
    if (event->type() == QSymbianEvent::WindowServerEvent
        && event->windowServerEvent()->Type() == EEventWindowVisibilityChanged) {
            TUint flags = event->windowServerEvent()->VisibilityChanged()->iFlags;
            if (flags & TWsVisibilityChangedEvent::ENotVisible)
                setVisibility(NotVisible);
            else if (flags & TWsVisibilityChangedEvent::EFullyVisible)
                setVisibility(FullyVisible);
            else
                setVisibility(PartiallyVisible);
    }
    return QApplication::symbianEventFilter(event);
}

void SymbianApplication::setVisibility(Visibility visibility)
{
    if (m_visibility == visibility)
        return;

    m_visibility = visibility;

    emit visibilityChanged();
}
