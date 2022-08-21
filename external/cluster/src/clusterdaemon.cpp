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

#include "clusterdaemon.h"
#include <QCoreApplication>
#include <QDebug>
#include <QtGlobal>
#include <csignal>
#ifdef Q_OS_UNIX
#include <unistd.h>
#endif

static void _daemonSignalHandler(int signal)
{
    Q_UNUSED(signal)
    // qDebug() << qUtf8Printable(QStringLiteral("Exit signal = ") + QString::number(signal));
    qApp->quit();
}

bool ClusterDaemon::initialize()
{
#ifdef Q_OS_WINDOWS
    typedef void (*SignalHandlerPointer)(int);
    SignalHandlerPointer sintHandler = 0;
    sintHandler = signal(SIGINT, _daemonSignalHandler);
    if (sintHandler == SIG_ERR) {
        qWarning() << QStringLiteral("ClusterDaemon::Init SIGINT error!");
        return false;
    }
    //
    SignalHandlerPointer stermHandler = 0;
    stermHandler = signal(SIGTERM, _daemonSignalHandler);
    if (stermHandler == SIG_ERR) {
        qWarning() << QStringLiteral("ClusterDaemon::Init SIGTERM error!");
        return false;
    }
    //
#ifdef SIGBREAK
    SignalHandlerPointer breakHandler = 0;
    breakHandler = signal(SIGBREAK, _daemonSignalHandler);
    if (breakHandler == SIG_ERR) {
        qWarning() << QStringLiteral("ClusterDaemon::Init SIGBREAK error!");
        return false;
    }
#endif
    //
    SignalHandlerPointer abortHandler = 0;
    abortHandler = signal(SIGABRT, _daemonSignalHandler);
    if (abortHandler == SIG_ERR) {
        qWarning() << QStringLiteral("ClusterDaemon::Init SIGABRT error!");
        return false;
    }
    return true;
#elif defined(Q_OS_UNIX)
    struct sigaction shup, sint, squit, sterm;
    //
    shup.sa_handler = _daemonSignalHandler;
    sigemptyset(&shup.sa_mask);
    shup.sa_flags = 0;
#ifdef SA_RESTART
    shup.sa_flags |= SA_RESTART;
#endif
    if (sigaction(SIGHUP, &shup, 0)) {
        qWarning() << QStringLiteral("ClusterDaemon::Init SIGHUP error!");
        return false;
    }
    //
    sint.sa_handler = _daemonSignalHandler;
    sigemptyset(&sint.sa_mask);
    sint.sa_flags = 0;
#ifdef SA_RESTART
    sint.sa_flags |= SA_RESTART;
#endif
    if (sigaction(SIGINT, &sint, 0)) {
        qWarning() << QStringLiteral("ClusterDaemon::Init SIGINT error!");
        return false;
    }
    //
    squit.sa_handler = _daemonSignalHandler;
    sigemptyset(&squit.sa_mask);
    squit.sa_flags = 0;
#ifdef SA_RESTART
    squit.sa_flags |= SA_RESTART;
#endif
    if (sigaction(SIGQUIT, &squit, 0)) {
        qWarning() << QStringLiteral("ClusterDaemon::Init SIGQUIT error!");
        return false;
    }
    //
    sterm.sa_handler = _daemonSignalHandler;
    sigemptyset(&sterm.sa_mask);
    sterm.sa_flags = 0;
#ifdef SA_RESTART
    sterm.sa_flags |= SA_RESTART;
#endif
    if (sigaction(SIGTERM, &sterm, 0)) {
        qWarning() << QStringLiteral("ClusterDaemon::Init SIGTERM error!");
        return false;
    }
    return true;
#else
    return false;
#endif
}
