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

#ifndef CLUSTER_LOG_H
#define CLUSTER_LOG_H

#include "clusterexport.h"
#include <QString>

namespace ClusterLog {
void CLUSTER_EXPORT install();
void CLUSTER_EXPORT printToBoot(const QString& log);
}
#endif // CLUSTER_LOG_H
