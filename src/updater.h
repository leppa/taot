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

#ifndef UPDATER_H
#define UPDATER_H

#include <QObject>
#include <QVariantList>

class Release: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString version READ version CONSTANT)
    Q_PROPERTY(QString title READ title CONSTANT)
    Q_PROPERTY(QString changeLog READ changeLog CONSTANT)

public:
    Release(QObject *parent = 0);
    Release(const QString &version,
            const QString &title,
            const QString &changeLog,
            QObject *parent = 0);

    QString version() const;
    QString title() const;
    QString changeLog() const;

private:
    QString m_version;
    QString m_title;
    QString m_changeLog;
};
Q_DECLARE_METATYPE(Release *)

class QNetworkAccessManager;
class QNetworkReply;
class Updater: public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(QString variant READ variant WRITE setVariant NOTIFY variantChanged)
    Q_PROPERTY(QString currentVersion READ currentVersion
                                      WRITE setCurrentVersion
                                      NOTIFY currentVersionChanged)
    Q_PROPERTY(Release *latestRelease READ latestRelease NOTIFY latestReleaseChanged)
    Q_PROPERTY(bool latestReleaseValid READ latestReleaseValid NOTIFY latestReleaseValidChanged)
    Q_PROPERTY(bool updateAvailable READ updateAvailable NOTIFY updateAvailableChanged)

public:
    explicit Updater(QObject *parent = 0);

    bool busy() const;

    QString variant() const;
    void setVariant(const QString &variant);

    QString currentVersion() const;
    void setCurrentVersion(const QString &currentVersion);

    Release *latestRelease() const;
    bool latestReleaseValid() const;
    bool updateAvailable() const;

signals:
    void busyChanged();
    void variantChanged();
    void currentVersionChanged();
    void latestReleaseChanged();
    void latestReleaseValidChanged();
    void updateAvailableChanged();
    void error(const QString &errorString);

public slots:
    void checkForUpdates();

private slots:
    void onNetworkReply(QNetworkReply *reply);

private:
    bool m_busy;
    QString m_variant;
    QString m_currentVersion;
    Release *m_latestRelease;
    bool m_latestReleaseValid;
    bool m_updateAvailable;

    int m_numericCurrentVersion;
    int m_numericLatestVersion;

    QNetworkAccessManager *m_nam;
    QNetworkReply *m_reply;

    void setBusy(bool busy);
    void setUpdateAvailable(bool available);
    int parseVersion(const QString versionString);
    QVariantList parseJson(const QByteArray &json);
};
Q_DECLARE_METATYPE(Updater *)

#endif // UPDATER_H
