/*********************************************************************************
 *Copyright(C): Juntuan.Lu, 2020-2030, All rights reserved.
 *Author:  Juntuan.Lu
 *Version: 1.0
 *Date:  2021/07/22
 *Email: 931852884@qq.com
 *Description:
 *Others:
 *Function List:
 *History:
 **********************************************************************************/

#include "cluster/clusterserverbase.h"
#include "cluster/clusterheartbeat.h"
#include "cluster/clusterlog.h"
#include "clusterdaemon.h"
#include <QCoreApplication>
#include <QTimer>

#ifdef CLUSTER_HAS_BOOT_DAEMON
#include <bootmanager/bootdaemon.h>
#endif

ClusterServerBase::ClusterServerBase()
    : m_reconnectTimer(new QTimer)
{
}

ClusterServerBase::~ClusterServerBase()
{
    delete m_reconnectTimer;
}

void ClusterServerBase::create(void* targetPtr, boot_daemon_callback_t fun)
{
    if (m_hasCreate) {
        return;
    }
    ClusterDaemon::initialize();
    m_appName = qApp->applicationName();
#ifdef QT_DEBUG
    if (m_appName.endsWith(QStringLiteral("d"))) {
        m_appName.chop(1);
    }
#endif
    m_heartbeatName = m_appName + QStringLiteral("-main");
    m_hostObject = new QRemoteObjectHost();
#ifdef CLUSTER_HAS_BOOT_DAEMON
    int reval = boot_create_bootwatch_inqtloop(m_appName.toUtf8(), fun, targetPtr);
    if (reval == 0) {
        qDebug() << qUtf8Printable(QStringLiteral("Control channel created successfully."));
    }
    ClusterHeartbeat::create(m_heartbeatName, CLUSTER_HEARTBEART_INTERVAL, m_hostObject);
#else
    (void)targetPtr;
    (void)fun;
#endif
    m_hasCreate = true;
}

void ClusterServerBase::destroy(QObject* sourceObj)
{
    if (!m_hasCreate) {
        return;
    }
    m_hostObject->disableRemoting(sourceObj);
    delete m_hostObject;
#ifdef CLUSTER_HAS_BOOT_DAEMON
    boot_remove_bootwatch(m_appName.toUtf8());
#endif
    if (m_reconnectTimer->isActive() == true) {
        m_reconnectTimer->stop();
    }
    m_hasCreate = false;
    m_hasConnect = false;
}

void ClusterServerBase::initialize(QObject* sourceObj, const QString& nodeName, const QUrl& url)
{
    if (!m_hasCreate) {
        return;
    }
    m_sourceObj = sourceObj;
    m_nodeName = nodeName;
    m_url = url;
    QObject::connect(m_reconnectTimer, &QTimer::timeout, [this]() {
        qWarning() << "ClusterSourceBaseProxy reconnect...";
        reconnect();
    });
    reconnect();
}

void ClusterServerBase::reconnect()
{
    if (m_hasConnect == false) {
        QUrl url = m_url;
        if (url.isEmpty()) {
            url = QUrl(QStringLiteral("local:") + m_nodeName);
        }
        m_hasConnect = m_hostObject->setHostUrl(url);
        if (m_hasConnect == true) {
            if (m_sourceObj) {
                bool isRemoted = m_hostObject->enableRemoting(m_sourceObj);
                if (isRemoted == false) {
                    qCritical() << QStringLiteral("Enable remoting failed !");
                }
            }
            if (m_reconnectTimer->isActive() == true) {
                m_reconnectTimer->stop();
            }
        } else {
            if (m_reconnectTimer->isActive() == false) {
                m_reconnectTimer->start(CLUSTER_RECONNECT_INTERVAL);
            }
        }
    }
}

void ClusterServerBase::finished()
{
#ifdef CLUSTER_HAS_BOOT_DAEMON
    boot_unlock(m_appName.toUtf8());
#endif
}

void ClusterServerBase::printConnected(bool connected)
{
    if (connected == true) {
        ClusterLog::printToBoot("Connected");
    } else {
        ClusterLog::printToBoot("Disconnected");
    }
}

void ClusterServerBase::quit()
{
    qApp->quit();
}

QRemoteObjectHost* ClusterServerBase::hostObject()
{
    return m_hostObject;
}

QString ClusterServerBase::hostName()
{
    return m_appName;
}
