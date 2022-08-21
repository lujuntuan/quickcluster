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

#include "clustermanager.h"
#include "rep_clusterivi_replica.h"
#include "rep_clusterivs_replica.h"

ClusterManager::ClusterManager(QObject* parent)
    : ClusterManagerBase(parent)
{
}

void ClusterManager::installPlugins()
{
    loadSkinPlugins(CLUSTER_TARGET_NAME);
}

void ClusterManager::installReplicas()
{
    qmlRegisterSingletonType<ClusterManager>("Cluster", 1, 0, "ClusterManager", [this](QQmlEngine*, QJSEngine*) {
        return this;
    });
    qmlRegisterSingletonType<ClusterIvsReplica>("Cluster", 1, 0, "ClusterIvs", [this](QQmlEngine*, QJSEngine*) {
        return getReplica<ClusterIvsReplica>();
    });
    qmlRegisterSingletonType<ClusterIviReplica>("Cluster", 1, 0, "ClusterIvi", [this](QQmlEngine*, QJSEngine*) {
        return getReplica<ClusterIviReplica>();
    });
}

void ClusterManager::receiveClientCommand(const QString& command)
{
    qDebug() << command;
    QStringList paras = command.split("=");
    if (paras.length() != 2) {
        return;
    }
    QString key = paras.at(0).toLower().trimmed();
    QString value = paras.at(1).toLower().trimmed();
    if (key == QStringLiteral("fpsvisible")) {
        setFpsVisible(value.toInt());
    }
    ClusterManagerBase::receiveClientCommand(command);
}
