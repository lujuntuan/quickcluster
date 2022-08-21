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

#ifndef CLUSTER_MANAGER_H
#define CLUSTER_MANAGER_H

#include <cluster/clustermanagerbase.h>

class ClusterManager : public ClusterManagerBase {
    Q_OBJECT
    Q_PROPERTY(bool hasAvNavi READ hasAvNavi CONSTANT);
    Q_PROPERTY(bool hasAvAnimation READ hasAvAnimation CONSTANT);

public:
    explicit ClusterManager(QObject* parent = nullptr);
    bool hasAvNavi() const
    {
#ifdef CLUSTER_QTAV_NAVI
        return true;
#else
        return false;
#endif
    }
    bool hasAvAnimation() const
    {
#ifdef CLUSTER_QTAV_ANIMATION
        return true;
#else
        return false;
#endif
    }

protected:
    void installPlugins() override;
    void installReplicas() override;
    void receiveClientCommand(const QString& command) override;
};

#endif // CLUSTER_MANAGER_H
