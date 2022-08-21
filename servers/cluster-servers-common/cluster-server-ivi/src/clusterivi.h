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

#ifndef CLUSTER_IVI_H
#define CLUSTER_IVI_H

#include "rep_clusterivi_source.h"
#include <cluster/clusterserverbase.h>

class ClusterIvi : public ClusterIviSimpleSource, public ClusterServerProxy<ClusterIvi> {
    Q_OBJECT
public:
    explicit ClusterIvi(QObject* parent = nullptr);
    ~ClusterIvi();

public slots:
    void dealMsg(const QString& msgName, const QVariant& msgData);
    void dealMediaPage();

private:
    void resetMedia();

public:
    bool getVersion(QString& text, int& majorNum, int& minorNum, int& revisionNum, bool& beta, QString& commitId);
    QString getSourceForImage(const QImage& image);

protected:
    void timerEvent(QTimerEvent* event) override;
    void receiveClientCommand(const QString& command) override;
};

#endif // CLUSTER_IVI_H
