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

#ifndef CLUSTER_IVS_H
#define CLUSTER_IVS_H

#include "rep_clusterivs_source.h"
#include <cluster/clusterserverbase.h>

class QPropertyAnimation;

class ClusterIvs : public ClusterIvsSimpleSource, public ClusterServerProxy<ClusterIvs> {
    Q_OBJECT
    Q_PROPERTY(float speed READ speed WRITE setSpeed)
    Q_PROPERTY(float engine READ engine WRITE setEngine)
    Q_PROPERTY(float battery READ battery WRITE setBattery)
    Q_PROPERTY(float fuel READ fuel WRITE setFuel)
    Q_PROPERTY(float water READ water WRITE setWater)

public:
    explicit ClusterIvs(QObject* parent = nullptr);
    ~ClusterIvs();
    void playSpeed(float value);
    void playEngine(float value);
    void playBattery(float value);
    void playFuel(float value);
    void playWater(float value);

protected:
    void timerEvent(QTimerEvent* event) override;
    void receiveClientCommand(const QString& command) override;

private:
    QPropertyAnimation* m_speedAnimation = nullptr;
    QPropertyAnimation* m_engineAnimation = nullptr;
    QPropertyAnimation* m_batteryAnimation = nullptr;
    QPropertyAnimation* m_fuelAnimation = nullptr;
    QPropertyAnimation* m_waterAnimation = nullptr;
};

#endif // CLUSTER_IVS_H
