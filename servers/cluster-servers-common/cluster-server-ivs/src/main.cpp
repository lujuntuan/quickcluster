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

#include "clusterivs.h"
#include <QCoreApplication>
#include <QDebug>
#include <QDir>
#include <cluster/clusterlog.h>
#include <cluster/clustermemory.h>

bool __ENABLE_TEST = false;

int main(int argc, char* argv[])
{
    ClusterLog::install();
    QCoreApplication app(argc, argv);
    QDir::setCurrent(app.applicationDirPath());
    if (ClusterMemory::initialize() == false) {
        return 1;
    }
    if (app.arguments().length() > 1) {
        if (app.arguments().at(1) == QStringLiteral("-test")) {
            __ENABLE_TEST = true;
            qDebug() << "Enable IVS Test...";
        }
    }
    ClusterIvs service;
    service.initialize();
    return app.exec();
}
