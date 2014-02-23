/*
 *  The Advanced Online Translator
 *  Copyright (C) 2013-2014  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
 *
 *  $Id: $Format:%h %ai %an$ $
 *
 *  This file is part of The Advanced Online Translator.
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

#include "updater.h"

#include <QRegExp>
#include <QStringList>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
#   include <QScriptEngine>
#   include <QScriptValue>
#else
#   include <QJsonDocument>
#endif
#include <QDebug>

Release::Release(QObject *parent)
    : QObject(parent)
{
}

Release::Release(const QString &version,
                 const QString &title,
                 const QString &changeLog,
                 QObject *parent)
    : QObject(parent)
    , m_version(version)
    , m_title(title)
    , m_changeLog(changeLog)
{
}

QString Release::version() const
{
    return m_version;
}

QString Release::title() const
{
    return m_title;
}

QString Release::changeLog() const
{
    return m_changeLog;
}

Updater::Updater(QObject *parent)
    : QObject(parent)
    , m_busy(false)
    , m_latestRelease(new Release(this))
    , m_latestReleaseValid(false)
    , m_updateAvailable(false)
    , m_reply(NULL)
{
    m_nam = new QNetworkAccessManager(this);
    connect(m_nam, SIGNAL(finished(QNetworkReply*)), SLOT(onNetworkReply(QNetworkReply*)));
}

bool Updater::busy() const
{
    return m_busy;
}

QString Updater::currentVersion() const
{
    return m_currentVersion;
}

void Updater::setCurrentVersion(const QString &currentVersion)
{
    if (m_currentVersion == currentVersion)
        return;

    m_currentVersion = currentVersion;
    m_numericCurrentVersion = parseVersion(m_currentVersion);
    emit currentVersionChanged();
}

Release *Updater::latestRelease() const
{
    return m_latestRelease;
}

bool Updater::latestReleaseValid() const
{
    return m_latestReleaseValid;
}

bool Updater::updateAvailable() const
{
    return m_updateAvailable;
}

void Updater::checkForUpdates()
{
    setBusy(true);

    if (m_reply && m_reply->isRunning())
        m_reply->abort();

    QUrl url("https://api.github.com/repos/leppa/taot/releases");
    m_reply = m_nam->get(QNetworkRequest(url));
}

void Updater::onNetworkReply(QNetworkReply *reply)
{
    if (reply != m_reply) {
        // Reply not for the latest request. Ignore it.
        reply->deleteLater();
        setBusy(false);
        return;
    }
    m_reply = NULL;

    if (reply->error() == QNetworkReply::OperationCanceledError) {
        // Operation was canceled by us, ignore this error.
        reply->deleteLater();
        setBusy(false);
        return;
    }

    if (reply->error() != QNetworkReply::NoError) {
        qWarning() << reply->errorString();
        emit error(reply->errorString());
        reply->deleteLater();
        setBusy(false);
        return;
    }

    const QVariantList releases = parseJson(reply->readAll());
    reply->deleteLater();
    if (releases.isEmpty()) {
        setBusy(false);
        return;
    }

    int k = 0;
    QVariantMap release = releases.at(0).toMap();
    while (release.value("prerelease").toBool()
           || release.value("draft").toBool()
           || release.value("tag_name").toString().contains("-")) {
        release = releases.at(++k).toMap();
    }

    const QString name = release.value("tag_name").toString();
    const QString title = release.value("name").toString();
    const QString changeLog = release.value("body").toString();

    const int version = parseVersion(name);
    if (version < 0) {
        emit error(tr("Couldn't parse release version"));
        setBusy(false);
        return;
    }

    m_numericLatestVersion = parseVersion(name);
    if (m_latestRelease)
        delete m_latestRelease;
    m_latestRelease = new Release(name, title, changeLog, this);
    emit latestReleaseChanged();

    if (!m_latestReleaseValid) {
        m_latestReleaseValid = true;
        emit latestReleaseValidChanged();
    }

    setUpdateAvailable(m_numericCurrentVersion < m_numericLatestVersion);
    setBusy(false);
}

void Updater::setBusy(bool busy)
{
    if (m_busy == busy)
        return;

    m_busy = busy;
    emit busyChanged();
}

void Updater::setUpdateAvailable(bool available)
{
    if (m_updateAvailable == available)
        return;

    m_updateAvailable = available;
    emit updateAvailableChanged();
}

int Updater::parseVersion(const QString versionString)
{
    QRegExp rx("(\\d+)\\.(\\d+)\\.(\\d+)(?:\\.(\\d+))?");
    if (rx.indexIn(versionString) < 0) {
        qDebug() << rx.errorString();
        return -1;
    }

    return (rx.capturedTexts().at(1).toInt() << 24)
            + (rx.capturedTexts().at(2).toInt() << 16)
            + (rx.capturedTexts().at(3).toInt() << 8)
            + rx.capturedTexts().at(4).toInt();
}

QVariantList Updater::parseJson(const QByteArray &json)
{
#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    QString js;
    js.reserve(json.size() + 2);
    js.append("(").append(QString::fromUtf8(json)).append(")");

    static QScriptEngine engine;
    if (!engine.canEvaluate(js)) {
        emit error(tr("Couldn't parse response from the server because of an error: \"%1\"")
                   .arg(tr("Can't evaluate JSON data")));
        return QVariantList();
    }

    QScriptValue data = engine.evaluate(js);
    if (engine.hasUncaughtException()) {
        emit error(tr("Couldn't parse response from the server because of an error: \"%1\"")
                   .arg(engine.uncaughtException().toString()));
        return QVariantList();
    }

    return data.toVariant().toList();
#else
    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(json, &err);

    if (err.error != QJsonParseError::NoError) {
        emit error(tr("Couldn't parse response from the server because of an error: \"%1\"")
                   .arg(err.errorString()));
        return QVariantList();
    }

    return doc.toVariant().toList();
#endif
}
