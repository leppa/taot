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

#ifndef DONATIONMANAGER_H
#define DONATIONMANAGER_H

#include <QObject>
#include <QStringList>

class QSettings;
namespace bb { namespace platform { class PaymentManager; } }
namespace bb { namespace platform { class PurchaseReply; } }
namespace bb { namespace platform { class ExistingPurchasesReply; } }
class DonationManager: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList tiers READ tiers CONSTANT)
    Q_PROPERTY(quint32 totalCoinCount READ totalCoinCount NOTIFY totalCoinCountChanged)

public:
    explicit DonationManager(QObject *parent = 0);
    QStringList tiers() const;
    quint32 totalCoinCount() const;
    Q_INVOKABLE void donate(int index);

signals:
    void donationSucceeded();
    void donationCanceled();
    void donationFailed(const QString &errorMessage);
    void totalCoinCountChanged();

private:
    void setTotalCoinCount(quint32 count);

private slots:
    void onExistingPurchasesFinished(bb::platform::ExistingPurchasesReply *reply);
    void onPurchaseFinished(bb::platform::PurchaseReply *reply);

private:
    bb::platform::PaymentManager *m_paymentManager;
    QStringList m_tiers;
    QList<quint16> m_coinsInTier;
    quint32 m_numCoins;
    QSettings *m_settings;
    mutable bool refreshDone;
};

#endif // DONATIONMANAGER_H
