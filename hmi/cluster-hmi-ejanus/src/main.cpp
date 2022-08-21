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
#include <QDir>
#include <QFont>
#include <QGuiApplication>
#include <cluster/clusterlog.h>
#include <cluster/clustermemory.h>
#include <mutex>

int main(int argc, char* argv[])
{
    ClusterLog::install();
    QGuiApplication app(argc, argv);
    QDir::setCurrent(app.applicationDirPath());
    if (ClusterMemory::initialize() == false) {
        return 1;
    }
#ifdef WIN32
    qApp->setFont(QFont(QStringLiteral("Microsoft YaHei UI")));
#endif
    ClusterManager manager;
#ifdef CLUSTER_IMAGE_CACHE
    manager.initialize(QUrl(QStringLiteral("qrc:/qml/main.qml")), true);
#else
    manager.initialize(QUrl(QStringLiteral("qrc:/qml/main.qml")), false);
#endif
    manager.show();
    return app.exec();
}
