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

#include "cluster/clustermemory.h"
#include <QCoreApplication>
#include <QDebug>
#include <QSharedMemory>
#include <QString>

QSharedMemory _clusterMainMem;

bool ClusterMemory::initialize()
{
    QString applicationName = qApp->applicationName();
#ifdef QT_DEBUG
    if (applicationName.endsWith(QStringLiteral("d"))) {
        applicationName.chop(1);
    }
#endif
    QString name = CLUSTER_MEM_CHECK_NAME + applicationName;
#ifdef Q_OS_UNIX
    QSharedMemory removeMem;
    removeMem.setKey(name);
    if (removeMem.attach(QSharedMemory::ReadOnly) == true) {
        removeMem.detach();
    }
#endif
    bool single = true;
    _clusterMainMem.setKey(name);
    if (_clusterMainMem.attach(QSharedMemory::ReadOnly) == true) {
        _clusterMainMem.detach();
        qWarning() << qUtf8Printable(QStringLiteral("The program has started !"));
        single = false;
    } else {
        if (_clusterMainMem.create(1, QSharedMemory::ReadOnly) == false) {
            qWarning() << qUtf8Printable(QStringLiteral("Create static memory failed !"));
            single = false;
        }
    }
    return single;
}

bool ClusterMemory::exists(const QString& name)
{
#ifdef Q_OS_UNIX
    QSharedMemory removeMem;
    removeMem.setKey(name);
    if (removeMem.attach(QSharedMemory::ReadOnly) == true) {
        removeMem.detach();
    }
#endif
    bool hasit = false;
    QSharedMemory mem;
    mem.setKey(name);
    if (mem.attach(QSharedMemory::ReadOnly) == true) {
        mem.detach();
        hasit = true;
    }
    return hasit;
}
