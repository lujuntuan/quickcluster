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

#ifndef BOOT_COMMON_H
#define BOOT_COMMON_H

#include <QVariant>

#define BOOT_CHECK_FSTR QStringLiteral("boot-startcheck-")
#define BOOT_CTRLKEY_FSTR QStringLiteral("boot-bootctrl-key")
#define BOOT_CANREAD_FSTR QStringLiteral("boot-r")
#define BOOT_CANWRITE_FSTR QStringLiteral("boot-w")
#define BOOT_RUN_FSTR QStringLiteral("boot-run")
#define BOOT_LOCK__FSTR QStringLiteral("boot-lock-")
#define BOOT_WATCH_FSTR QStringLiteral("boot-watch-")
#define BOOT_HEARTBEAT_FSTR QStringLiteral("boot-heartbeat-")
#define BOOT_SEMA_FSTR QStringLiteral("-semaphore")
#define BOOT_SIZE 1024
#define BOOT_RETRY_TIMES 3

class QSharedMemory;

namespace BootCommon {
enum Type {
    UNKNOWN = 0,
    SINGLE_COMMAND,
    DOUBLE_COMMAND,
    THREE_COMMAND,
    HEARDBEAT = 100,
};
qint64 getCurrentTimeMs();
bool waitSemaphore(const QString& key);
bool releaseSemaphore(const QString& key);
bool clearMemory(QSharedMemory* mem);
bool writeMemory(QSharedMemory* mem, int type = UNKNOWN, const QVariant& content = QVariant(), bool force = false);
bool readMemory(QSharedMemory* mem, int* type = nullptr, QVariant* content = nullptr, qint64* time = nullptr, bool force = false);
}

#endif // BOOT_COMMON_H
