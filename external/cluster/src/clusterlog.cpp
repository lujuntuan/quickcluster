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

#include "cluster/clusterlog.h"
#include <QCoreApplication>
#include <QDebug>
#include <QString>
#include <iostream>

static void _logMsgOutput(QtMsgType type, const QMessageLogContext& context, const QString& msg)
{
    Q_UNUSED(type)
    QString printMsg = msg;
    if (CLUSTER_DEBUG_LOG) {
        QString textMsg = QStringLiteral("%1 *{ file: %2, line: %3, func: %4 }*").arg(printMsg, QString(context.file), QString::number(context.line), QString(context.function));
        switch (type) {
        case QtDebugMsg:
            textMsg.prepend(QStringLiteral("Debug: "));
            break;
        case QtInfoMsg:
            //            textMsg.prepend(QStringLiteral("Info: "));
            break;
        case QtWarningMsg:
            textMsg.prepend(QStringLiteral("Warning: "));
            break;
        case QtCriticalMsg:
            textMsg.prepend(QStringLiteral("Critical: "));
            break;
        case QtFatalMsg:
            textMsg.prepend(QStringLiteral("Fatal: "));
            break;
        }
        fprintf(stdout, "%s\n", textMsg.toLocal8Bit().constData());
        fflush(stdout);
    } else {
        fprintf(stdout, "%s\n", printMsg.toLocal8Bit().constData());
        fflush(stdout);
    }
}

void ClusterLog::install()
{
    //    setvbuf(stdout, nullptr, _IONBF, 0);
    //    setvbuf(stderr, nullptr, _IONBF, 0);
    qInstallMessageHandler(_logMsgOutput);
}

void ClusterLog::printToBoot(const QString& log)
{
    QString printStr = log;
#ifdef CLUSTER_HAS_BOOT_DAEMON
    printStr.prepend(QStringLiteral(CLUSTER_LOG_STR));
#endif
    fprintf(stdout, "%s\n", printStr.toLocal8Bit().constData());
    fflush(stdout);
}
