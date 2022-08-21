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

#ifndef CLUSTER_MEMORY_H
#define CLUSTER_MEMORY_H

#include "clusterexport.h"
#include <QString>

#define CLUSTER_MEM_CHECK_NAME QStringLiteral("cluster-startcheck-")

namespace ClusterMemory {
bool CLUSTER_EXPORT initialize();
bool CLUSTER_EXPORT exists(const QString& name);
}

#endif // CLUSTER_MEMORY_H
