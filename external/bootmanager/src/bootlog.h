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

#ifndef BOOT_LOG_H
#define BOOT_LOG_H

#include <QString>

namespace BootLog {
void install();
void unInstall();
void printDebug(const QString& str, bool print = true, bool cache = true);
void printInfo(const QString& processStr, const QString& str, bool print = true, bool cache = true);
void printBootInfo(const QString& processStr, const QString& str, bool print = true, bool cache = true);
void printWarning(const QString& str, bool print = true, bool cache = true);
void printCritical(const QString& str, bool print = true, bool cache = true);
void printFatal(const QString& str, bool print = true, bool cache = true);
}
#endif // BOOT_LOG_H
