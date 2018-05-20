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

#include "donationmanager.h"

#include <QSettings>
#include <bb/cascades/Application>
#include <bb/cascades/Window>
#include <bb/platform/PaymentManager>
#include <bb/platform/PurchaseReply>
//#include <bb/platform/PaymentErrorCode>
#include <bb/platform/ExistingPurchasesReply>

DonationManager::DonationManager(QObject *parent)
    : QObject(parent)
    , m_numCoins(0)
    , m_settings(NULL)
    , refreshDone(false)
{
    m_paymentManager = new bb::platform::PaymentManager(this);
    m_paymentManager->setWindowGroupId(bb::cascades::Application::instance()->mainWindow()->groupId());
    connect(m_paymentManager, SIGNAL(purchaseFinished(bb::platform::PurchaseReply*)),
            this, SLOT(onPurchaseFinished(bb::platform::PurchaseReply*)));
    connect(m_paymentManager, SIGNAL(existingPurchasesFinished(bb::platform::ExistingPurchasesReply*)),
            this, SLOT(onExistingPurchasesFinished(bb::platform::ExistingPurchasesReply*)));

    m_tiers << tr("%n coins", "", 6);
    m_coinsInTier << 6;

    m_tiers << tr("%n coins", "", 13);
    m_coinsInTier << 13;

    m_tiers << tr("%n coins", "", 34);
    m_coinsInTier << 34;

    m_tiers << tr("%n coins", "", 69);
    m_coinsInTier << 69;

    m_tiers << tr("%n coins", "", 139);
    m_coinsInTier << 139;

    m_settings = new QSettings(QCoreApplication::organizationName(), "taot", this);
}

QStringList DonationManager::tiers() const
{
    return m_tiers;
}

quint32 DonationManager::totalCoinCount() const
{
    if (!refreshDone) {
        refreshDone = true;
        const bool forceServerRefresh = m_settings->value("FirstStart/ExistingDonationsRetrieved",
                                                          true).toBool();
        m_paymentManager->requestExistingPurchases(forceServerRefresh);
    }

    return m_numCoins;
}

void DonationManager::donate(int index)
{
    if (index < 0 || index >= m_coinsInTier.size())
        return;

    const quint16 numCoins = m_coinsInTier.at(index);
    const QString sku = QString("TAOT%1COINS").arg(numCoins);

    QVariantMap extra;
    extra.insert("numCoins", numCoins);

    QByteArray data;
    QDataStream stream(&data, QIODevice::WriteOnly);
    stream << quint8(1); // Metadata version
    stream << numCoins;
    m_paymentManager->requestPurchase(QString(),
                                      sku,
                                      QString(),
                                      QString::fromLatin1(data.toBase64()),
                                      extra);
}

void DonationManager::setTotalCoinCount(quint32 count)
{
    if (m_numCoins == count)
        return;

    m_numCoins = count;
    emit totalCoinCountChanged();
}

void DonationManager::onExistingPurchasesFinished(bb::platform::ExistingPurchasesReply *reply)
{
    if (reply->errorCode() != 0 /*bb::platform::PaymentErrorCode::None*/) {
        return;
    }

    quint32 count = 0;
    foreach (const bb::platform::PurchaseReceipt &purchase, reply->purchases()) {
        if (purchase.state() != bb::platform::DigitalGoodState::Owned)
            continue;

        QDataStream stream(QByteArray::fromBase64(purchase.purchaseMetadata().toLatin1()));

        quint8 version;
        stream >> version;
        if (version != 1 || stream.atEnd() || stream.status() != QDataStream::Ok)
            continue;

        quint16 numCoins = 0;
        stream >> numCoins;
        if (stream.status() != QDataStream::Ok)
            continue;

        count += numCoins;
    }
    reply->deleteLater();

    if (m_settings) {
        m_settings->setValue("FirstStart/ExistingDonationsRetrieved", false);
        delete m_settings;
        m_settings = NULL;
    }

    setTotalCoinCount(count);
}

void DonationManager::onPurchaseFinished(bb::platform::PurchaseReply *reply)
{
    if (reply->errorCode() == 1 /*bb::platform::PaymentErrorCode::Canceled*/)
        return;

    if (reply->errorCode() != 0 /*bb::platform::PaymentErrorCode::None*/) {
        emit donationFailed(reply->errorText());
        return;
    }

    bool ok;
    int count = reply->receipt().extraParameters().value("numCoins").toUInt(&ok);
    if (ok && count > 0) {
        count += m_numCoins;
        setTotalCoinCount(count);
    }

    emit donationSucceeded();
}
