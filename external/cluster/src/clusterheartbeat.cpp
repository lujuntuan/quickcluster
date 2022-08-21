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

#ifdef CLUSTER_HAS_BOOT_DAEMON
#include "cluster/clusterheartbeat.h"
#include <QDebug>
#include <QElapsedTimer>
#include <QMutex>
#include <bootmanager/bootdaemon.h>

void ClusterHeartbeat::create(const QString& name, int interval, QObject* parent)
{
    new ClusterHeartbeat(name, interval, parent);
}

ClusterHeartbeat::ClusterHeartbeat(const QString& name, int interval, QObject* parent)
    : QThread(parent)
    , m_interval(interval)
    , m_name(name)
{
    if (name.isEmpty()) {
        return;
    }
    if (interval < 10) {
        return;
    }
    this->start();
}

ClusterHeartbeat::~ClusterHeartbeat()
{
    if (this->isFinished()) {
        return;
    }
    m_waitCondition.notify_all();
    this->requestInterruption();
    this->quit();
    this->wait();
}

void ClusterHeartbeat::run()
{
    QMutex mutex;
    mutex.lock();
    int reval = 0;
    reval = boot_create_heartbeat(m_name.toUtf8());
    if (reval != 0) {
        mutex.unlock();
        return;
    }
    qDebug() << qUtf8Printable(QStringLiteral("Heartbeat channel created successfully."));
    for (;;) {
        m_waitCondition.wait(&mutex, QDeadlineTimer(m_interval));
        if (this->isInterruptionRequested()) {
            break;
        }
        reval = boot_send_heartbeat(m_name.toUtf8());
        if (reval != 0) {
            // qWarning() << QStringLiteral("SendHeartbeat error %1!").arg(QString::number(reval));
        }
    }
    reval = boot_remove_heartbeat(m_name.toUtf8());
    if (reval != 0) {
        // qWarning() << qUtf8Printable(QStringLiteral("RemoveHeartbeat error %1!").arg(QString::number(reval)));
    }
    mutex.unlock();
}
#endif
