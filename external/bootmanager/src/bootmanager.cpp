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

#include "bootmanager.h"
#include "bootchecker.h"
#include "bootlog.h"
#include "bootprocess.h"
#include "common/bootcommon.h"
#include <QAtomicInt>
#include <QCoreApplication>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QSharedMemory>
#include <QTimerEvent>

#ifdef Q_OS_UNIX
#include <unistd.h>
#endif

QAtomicInt _bootCloseFlag(0);

BootManager::BootManager(QObject* parent)
    : QObject(parent)
    , m_checker(new BootChecker(this))
    , m_clientMem(new QSharedMemory(this))
{
    qDebug();
    BootLog::printWarning(QStringLiteral("Bootmanager Initializing..."));
    qDebug();
}

BootManager::~BootManager()
{
}

void BootManager::init()
{
    if (m_hasInit) {
        return;
    }
    m_checker->start();
    m_hasInit = true;
}

void BootManager::destroy()
{
    m_checker->requestInterruption();
    BootCommon::releaseSemaphore(BOOT_CTRLKEY_FSTR);
    m_checker->quit();
    m_checker->wait();
    //
    for (BootProcess* process : qAsConst(m_listProcess)) {
        if (process) {
            delete process;
        }
    }
    m_listProcess.clear();
    //------
    for (BootProcess* process : qAsConst(m_listDestroyProcess)) {
        process->prepare();
        process->init();
        process->destroyPrepare();
        delete process;
    }
    m_listDestroyProcess.clear();
    //
    if (m_clientMem->isAttached()) {
        m_clientMem->detach();
    }
    delete m_clientMem;
    //
    qDebug();
    BootLog::printWarning(QStringLiteral("Bootmanager Destroyed."));
    qDebug();
    close();
}

void BootManager::startDestroyWork()
{
    qApp->quit();
}

void BootManager::close()
{
#ifdef Q_OS_UNIX
    sync();
    if (_bootCloseFlag == 1) {
#ifdef Q_OS_QNX
        BootLog::printWarning(QStringLiteral("shutdown -b"));
        system("shutdown -b");
#else
        BootLog::printWarning(QStringLiteral("poweroff -f"));
        system("poweroff -f");
#endif
    } else if (_bootCloseFlag == 2) {
#ifdef Q_OS_QNX
        BootLog::printWarning(QStringLiteral("reset"));
        system("reset");
#else
        BootLog::printWarning(QStringLiteral("reboot -f"));
        system("reboot -f");
#endif
    }
#endif
}
