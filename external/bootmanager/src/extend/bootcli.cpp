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

#include "common/bootcommon.h"
#include <QCoreApplication>
#include <QDebug>
#include <QDir>
#include <QElapsedTimer>
#include <QProcess>
#include <QSharedMemory>
#include <QSystemSemaphore>
#include <QThread>

QString _args = QStringLiteral(
    "help\n"
    "version\n"
    "-----------\n"
    "start/run/open\n"
    "stop/exit/close\n"
    "poweroff/shutdown\n"
    "reboot/reset\n"
    "scan\n"
    "list\n"
    "wait\n"
    "<component> start/run/open\n"
    "<component> stop/exit/close\n"
    "<component> enable\n"
    "<component> disable\n"
    "<component> moveup\n"
    "<component> movedown\n"
    "<component> detail\n"
    "<component> [command]");

int main(int argc, char* argv[])
{
    QCoreApplication app(argc, argv);
    QDir::setCurrent(app.applicationDirPath());
    if (app.arguments().length() != 2 && app.arguments().length() != 3) {
        qDebug() << qUtf8Printable(QStringLiteral("Usage:\n") + _args);
        if (app.arguments().length() == 1) {
            return 0;
        }
        return -1;
    }
    QString command1 = app.arguments().at(1);
    QString arg1 = command1.trimmed().toLower();
    QString command2;
    if (app.arguments().length() == 3) {
        command2 = app.arguments().at(2);
    } else {
        if (arg1 == QStringLiteral("--help") || arg1 == QStringLiteral("-help") || arg1 == QStringLiteral("help")
            || arg1 == QStringLiteral("--h") || arg1 == QStringLiteral("-h") || arg1 == QStringLiteral("h")) {
            qDebug() << qUtf8Printable(QStringLiteral("Usage:\n") + _args);
            return 0;
        } else if (arg1 == QStringLiteral("--version") || arg1 == QStringLiteral("-version") || arg1 == QStringLiteral("version")
            || arg1 == QStringLiteral("--v") || arg1 == QStringLiteral("-v") || arg1 == QStringLiteral("v")) {
            qDebug() << qUtf8Printable(QStringLiteral("Version: ") + QStringLiteral(CLUSTER_VERSION));
            qDebug() << qUtf8Printable(QStringLiteral("CommitID: ") + QStringLiteral(CLUSTER_COMMITID));
            return 0;
        } else if (arg1 == QStringLiteral("start") || arg1 == QStringLiteral("run") || arg1 == QStringLiteral("open")) {
            QProcess::startDetached(QStringLiteral("./bootmanager"), QStringList());
            return 0;
        } else if (arg1 == QStringLiteral("wait")) {
            BootCommon::waitSemaphore(BOOT_RUN_FSTR + BOOT_SEMA_FSTR);
            return 0;
        }
    }
    QSystemSemaphore semaphore(QStringLiteral("Semaphore_") + BOOT_CTRLKEY_FSTR, 1, QSystemSemaphore::Open);
    semaphore.acquire();
    QSharedMemory mem;
    mem.setKey(BOOT_CTRLKEY_FSTR);
    if (mem.attach(QSharedMemory::ReadWrite) == false) {
        qWarning() << qUtf8Printable(QStringLiteral("Bootmanager Is Not Running or Busying!"));
        semaphore.release();
        return -2;
    }
    bool ok = BootCommon::writeMemory(&mem, BootCommon::DOUBLE_COMMAND, QStringList() << command1 << command2);
    if (ok) {
        ok = BootCommon::releaseSemaphore(mem.key());
    }
    mem.detach();
    semaphore.release();
    if (ok == false) {
        qWarning() << qUtf8Printable(QStringLiteral("Bootmanager Write Memory Error!"));
        return -3;
    }
    return 0;
}
