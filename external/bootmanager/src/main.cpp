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

#include "bootlog.h"
#include "bootmanager.h"
#include "common/bootcommon.h"
#include <QCoreApplication>
#include <QDebug>
#include <QDir>
#include <QElapsedTimer>
#include <QFile>
#include <QSharedMemory>

QElapsedTimer _bootLogTimer;
QSharedMemory _mainMem;

static bool InitializeMem()
{
    QString applicationName = qApp->applicationName();
#ifdef QT_DEBUG
    if (applicationName.endsWith(QStringLiteral("d"))) {
        applicationName.chop(1);
    }
#endif
    QString name = BOOT_CHECK_FSTR + applicationName;
#ifdef Q_OS_UNIX
    QSharedMemory removeMem(name);
    if (removeMem.attach(QSharedMemory::ReadOnly) == true) {
        removeMem.detach();
    }
#endif
    bool single = true;
    _mainMem.setKey(name);
    if (_mainMem.attach(QSharedMemory::ReadOnly) == true) {
        _mainMem.detach();
        qWarning() << qUtf8Printable(QStringLiteral("The program has started !"));
        single = false;
    } else {
        if (_mainMem.create(1, QSharedMemory::ReadOnly) == false) {
            qWarning() << qUtf8Printable(QStringLiteral("Create static memory failed !"));
            single = false;
        }
    }
    return single;
}

int main(int argc, char* argv[])
{
    _bootLogTimer.start();
    BootLog::install();
    if (!InitializeMem()) {
        return 1;
    }
    QCoreApplication app(argc, argv);
    QDir::setCurrent(app.applicationDirPath());
    BootManager manager;
    manager.init();
    int reval = app.exec();
    manager.destroy();
    BootLog::unInstall();
    return reval;
}
