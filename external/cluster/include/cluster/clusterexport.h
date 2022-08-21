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

#ifndef CLUSTER_EXPORT_H
#define CLUSTER_EXPORT_H

#if defined(CLUSTER_LIBRARY_STATIC)
#define CLUSTER_EXPORT
#else
#if (defined _WIN32 || defined _WIN64)
#if defined(CLUSTER_LIBRARY)
#define CLUSTER_EXPORT __declspec(dllexport)
#else
#define CLUSTER_EXPORT __declspec(dllimport)
#endif
#else
#define CLUSTER_EXPORT
#endif
#endif

#endif // CLUSTER_EXPORT_H
