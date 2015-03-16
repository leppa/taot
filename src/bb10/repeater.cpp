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

#include "repeater.h"

#include <bb/cascades/DataModel>
#include <bb/cascades/Container>

using namespace bb::cascades;

Repeater::Repeater(Container *parent)
    : CustomControl(parent)
    , m_model(NULL)
    , m_delegate(NULL)
{
    setVisible(false);
}

DataModel *Repeater::model() const
{
    return m_model;
}

void Repeater::setModel(DataModel *model)
{
    if (m_model == model)
        return;

    clear();
    if (m_model)
        m_model->disconnect(this);

    m_model = model;

    createDelegates();
    connect(m_model,
            SIGNAL(itemAdded(QVariantList)),
            SLOT(onItemAddedRemovedOrUpdated(QVariantList)));
    connect(m_model,
            SIGNAL(itemRemoved(QVariantList)),
            SLOT(onItemAddedRemovedOrUpdated(QVariantList)));
    connect(m_model,
            SIGNAL(itemUpdated(QVariantList)),
            SLOT(onItemAddedRemovedOrUpdated(QVariantList)));
    connect(m_model,
            SIGNAL(itemsChanged(bb::cascades::DataModelChangeType::Type,
                                QSharedPointer<bb::cascades::DataModel::IndexMapper>)),
            SLOT(onItemsChanged(bb::cascades::DataModelChangeType::Type,
                                QSharedPointer<bb::cascades::DataModel::IndexMapper>)));

    emit modelChanged();
}

QDeclarativeComponent* Repeater::delegate() const
{
    return m_delegate;
}

void Repeater::setDelegate(QDeclarativeComponent *delegate)
{
    if (m_delegate == delegate)
        return;

    clear();
    m_delegate = delegate;
    createDelegates();

    emit delegateChanged();
}

void Repeater::onItemAddedRemovedOrUpdated(const QVariantList &)
{
    clear();
    createDelegates();
}

void Repeater::onItemsChanged(DataModelChangeType::Type, QSharedPointer<DataModel::IndexMapper>)
{
    clear();
    createDelegates();
}

void Repeater::clear()
{
    Container *container = qobject_cast<Container *>(parent());
    foreach (Control *control, m_controls) {
        container->remove(control);
    }

    qDeleteAll(m_controls);
    m_controls.clear();
}

void Repeater::createDelegates()
{
    if (!m_delegate || !m_model)
        return;

    Container *container = qobject_cast<Container *>(parent());
    const int pos = container->indexOf(this);

    for (int i = 0; i < m_model->childCount(QVariantList()); i++) {
        QDeclarativeContext *context = new QDeclarativeContext(m_delegate->creationContext(), this);

        QVariantList indexPath;
        indexPath.append(i);
        const QVariantMap map = m_model->data(indexPath).toMap();
        foreach (const QString &key, map.keys()) {
            context->setContextProperty(key, map.value(key));
        }

        Control *control = qobject_cast<Control *>(m_delegate->create(context));
        m_controls.append(control);
        container->insert(pos + i + 1, control);
    }
}
