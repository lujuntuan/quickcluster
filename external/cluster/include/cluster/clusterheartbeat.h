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

#ifndef CLUSTER_HEARTBEAT_H
#define CLUSTER_HEARTBEAT_H

#ifdef CLUSTER_HAS_BOOT_DAEMON

#include "clusterexport.h"
#include <QThread>
#include <QWaitCondition>

class CLUSTER_EXPORT ClusterHeartbeat : protected QThread {
public:
    static void create(const QString& name, int interval, QObject* parent = nullptr);

public:
    ClusterHeartbeat(const QString& name, int interval, QObject* parent = nullptr);
    ~ClusterHeartbeat();

private:
    int m_interval = 0;
    QString m_name;
    QWaitCondition m_waitCondition;

private:
    void run();
};
#endif

#endif // CLUSTER_HEARTBEAT_H
