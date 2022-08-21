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
#include <QDateTime>
#include <QDebug>
#include <QDir>
#include <QElapsedTimer>
#include <QFile>
#include <QMutex>
#include <QString>
#include <iostream>

#ifdef Q_OS_UNIX
#include <unistd.h>
#endif

#ifdef CLUSTER_HAS_DLT
#include <dlt/dlt.h>
#endif

#define OPCOLO_RESET QStringLiteral("\033[0m")
#define OPCOLO_UNDERLINE QStringLiteral("\33[4m")
#define OPCOLO_BLACK QStringLiteral("\033[30m") /* Black */
#define OPCOLO_RED QStringLiteral("\033[31m") /* Red */
#define OPCOLO_GREEN QStringLiteral("\033[32m") /* Green */
#define OPCOLO_YELLOW QStringLiteral("\033[33m") /* Yellow */
#define OPCOLO_BLUE QStringLiteral("\033[34m") /* Blue */
#define OPCOLO_MAGENTA QStringLiteral("\033[35m") /* Magenta */
#define OPCOLO_CYAN QStringLiteral("\033[36m") /* Cyan */
#define OPCOLO_WHITE QStringLiteral("\033[37m") /* White */
#define OPCOLO_BACKGROUND_BLACK QStringLiteral("\033[40;37m") /* Background Black */
#define OPCOLO_BACKGROUND_RED QStringLiteral("\033[41;37m") /* Background Red */
#define OPCOLO_BACKGROUND_GREEN QStringLiteral("\033[42;37m") /* Background Green */
#define OPCOLO_BACKGROUND_YELLOW QStringLiteral("\033[43;37m") /* Background Yellow */
#define OPCOLO_BACKGROUND_BLUE QStringLiteral("\033[44;37m") /* Background Blue */
#define OPCOLO_BACKGROUND_MAGENTA QStringLiteral("\033[45;37m") /* Background Magenta */
#define OPCOLO_BACKGROUND_CYAN QStringLiteral("\033[46;37m") /* Background Cyan */
#define OPCOLO_BACKGROUND_WHITE QStringLiteral("\033[47;37m") /* Background White */
#define OPCOLO_BOLD_BLACK QStringLiteral("\033[1m\033[30m") /* Bold Black */
#define OPCOLO_BOLD_RED QStringLiteral("\033[1m\033[31m") /* Bold Red */
#define OPCOLO_BOLD_GREEN QStringLiteral("\033[1m\033[32m") /* Bold Green */
#define OPCOLO_BOLD_YELLOW QStringLiteral("\033[1m\033[33m") /* Bold Yellow */
#define OPCOLO_BOLD_BLUE QStringLiteral("\033[1m\033[34m") /* Bold Blue */
#define OPCOLO_BOLD_MAGENTA QStringLiteral("\033[1m\033[35m") /* Bold Magenta */
#define OPCOLO_BOLD_CYAN QStringLiteral("\033[1m\033[36m") /* Bold Cyan */
#define OPCOLO_BOLD_WHITE QStringLiteral("\033[1m\033[37m") /* Bold White */

#ifdef TARGET_OS
#define CACHELOG_DIR QStringLiteral("/bootmanager_logs/")
#else
#define CACHELOG_DIR QStringLiteral("./bootmanager_logs/")
#endif

QMutex _logMutex;
QFile _logFile;
QString _startTimeStr = QDateTime::currentDateTime().toString(QStringLiteral("yyyy-MM-dd-hh-mm-ss-z"));
QDir _logDir(CACHELOG_DIR);
int _appendTimes = 0;

extern QElapsedTimer _bootLogTimer;

#ifdef CLUSTER_HAS_DLT
DLT_DECLARE_CONTEXT(dltCtx_);
#endif

void writeBootLogToPlatform(const QString& appName, const QString& log)
{
    QString targetLog = log;
    (void)appName;
    (void)targetLog;
#if defined(Q_OS_LINUX)
    QFile file("/dev/kmsg");
    if (file.exists()) {
        if (file.open(QFile::WriteOnly)) {
            targetLog.prepend(QStringLiteral("[%1] ").arg(appName));
            targetLog.append(QStringLiteral("\n"));
            file.write(targetLog.toUtf8());
            file.close();
        }
    }
#elif defined(Q_OS_QNX)
    QFile file("/dev/bmetrics");
    if (file.exists()) {
        if (file.open(QFile::WriteOnly)) {
            targetLog.prepend(QStringLiteral("bootmarker [%1] ").arg(appName));
            targetLog.append(QStringLiteral("\n"));
            file.write(targetLog.toUtf8());
            file.close();
        }
    }
#endif
}

void checkCacheLogDir()
{
    if (!_logDir.exists()) {
        QDir().mkpath(CACHELOG_DIR);
    }
    QFileInfoList dirList = _logDir.entryInfoList(QStringList() << QStringLiteral("*.log"), QDir::Files, QDir::Time);
    if (dirList.length() >= 20) {
        QFile::remove(dirList.last().filePath());
        checkCacheLogDir();
    }
}

void resetLogFile(bool part)
{
    if (_logFile.isOpen()) {
        _logFile.close();
    }
    QString partFlagStr;
    if (part == true) {
        partFlagStr = QStringLiteral("_part") + QString::number(_appendTimes);
    }
    _appendTimes++;
    _logFile.setFileName(CACHELOG_DIR + _startTimeStr + partFlagStr + QStringLiteral(".log"));
    _logFile.open(QFile::Text | QFile::WriteOnly | QFile::Truncate);
}

void writeLog(const QString& logStr)
{
    if (_logFile.size() > 1024 * 1024 * 5) { // 5MB
        checkCacheLogDir();
        resetLogFile(true);
    }
    if (_logFile.isOpen() == true) {
        QString writeMsg = QTime::currentTime().toString(QStringLiteral("hh:mm:ss.zzz")) + QStringLiteral(": ") + logStr + QStringLiteral("\n");
        _logFile.write(writeMsg.toLocal8Bit().constData());
        _logFile.flush();
    }
}

void LogMsgOutput(QtMsgType type, const QMessageLogContext& context, const QString& msg)
{
    Q_UNUSED(type);
    Q_UNUSED(context);
    QByteArray printArray = msg.toLocal8Bit();
    fprintf(stdout, "%s\n", printArray.constData());
    fflush(stdout);
}

void BootLog::install()
{
#ifdef CLUSTER_HAS_DLT
    DLT_REGISTER_APP("Bootmanager", "Application for Logging");
    DLT_REGISTER_CONTEXT(dltCtx_, "Bootmanager", "Context for Logging");
#endif
    //    setvbuf(stdout, nullptr, _IONBF, 0);
    //    setvbuf(stderr, nullptr, _IONBF, 0);
    checkCacheLogDir();
    resetLogFile(false);
    qInstallMessageHandler(LogMsgOutput);
}

void BootLog::unInstall()
{
#ifdef CLUSTER_HAS_DLT
    DLT_UNREGISTER_CONTEXT(dltCtx_);
    DLT_UNREGISTER_APP();
    dlt_free();
#endif
    if (_logFile.isOpen() == true) {
        _logFile.close();
    }
}

void BootLog::printDebug(const QString& str, bool print, bool cache)
{
    QMutexLocker locker(&_logMutex);
    Q_UNUSED(locker);
    if (print) {
        QString msgStr = str;
        msgStr.prepend(OPCOLO_BOLD_BLUE);
        msgStr.append(OPCOLO_RESET);
        qDebug() << qUtf8Printable(msgStr);
    }
#ifdef CLUSTER_HAS_DLT
    DLT_LOG(dltCtx_, DLT_LOG_DEBUG, DLT_STRING(str.toLocal8Bit()));
#else
    if (cache) {
        writeLog(str);
    }
#endif
}

void BootLog::printInfo(const QString& processStr, const QString& str, bool print, bool cache)
{
    QMutexLocker locker(&_logMutex);
    Q_UNUSED(locker);
    if (print) {
        QString msgStr = QStringLiteral("[") + processStr + QStringLiteral("] ");
        msgStr.prepend(OPCOLO_BOLD_GREEN);
        msgStr.append(OPCOLO_RESET);
        msgStr.append(OPCOLO_GREEN);
        msgStr.append(str);
        msgStr.append(OPCOLO_RESET);
        qInfo() << qUtf8Printable(msgStr);
    }
#ifdef CLUSTER_HAS_DLT
    DLT_LOG(dltCtx_, DLT_LOG_INFO, DLT_STRING(str.toLocal8Bit()));
#else
    if (cache) {
        writeLog(QStringLiteral("[") + processStr + QStringLiteral("] ") + str);
    }
#endif
}

void BootLog::printBootInfo(const QString& processStr, const QString& str, bool print, bool cache)
{
    QMutexLocker locker(&_logMutex);
    Q_UNUSED(locker);
    //
    writeBootLogToPlatform(processStr, str);
    //
    QString targetStr = QStringLiteral("%1 at %2 seconds").arg(str, QString::number(_bootLogTimer.elapsed() / 1000.0f, 'f', 3));
    if (print) {
        QString msgStr = QStringLiteral("[") + processStr + QStringLiteral("] ");
        msgStr.prepend(OPCOLO_BOLD_CYAN);
        msgStr.append(OPCOLO_RESET);
        msgStr.append(OPCOLO_CYAN);
        msgStr.append(targetStr);
        msgStr.append(OPCOLO_RESET);
        qInfo() << qUtf8Printable(msgStr);
    }
#ifdef CLUSTER_HAS_DLT
    DLT_LOG(dltCtx_, DLT_LOG_INFO, DLT_STRING(str.toLocal8Bit()));
#else
    if (cache) {
        writeLog(QStringLiteral("[") + processStr + QStringLiteral("] ") + targetStr);
    }
#endif
}

void BootLog::printWarning(const QString& str, bool print, bool cache)
{
    QMutexLocker locker(&_logMutex);
    Q_UNUSED(locker);
    if (print) {
        QString msgStr = str;
        msgStr.prepend(OPCOLO_BOLD_MAGENTA);
        msgStr.append(OPCOLO_RESET);
        qWarning() << qUtf8Printable(msgStr);
    }
#ifdef CLUSTER_HAS_DLT
    DLT_LOG(dltCtx_, DLT_LOG_WARN, DLT_STRING(str.toLocal8Bit()));
#else
    if (cache) {
        writeLog(str);
    }
#endif
}

void BootLog::printCritical(const QString& str, bool print, bool cache)
{
    QMutexLocker locker(&_logMutex);
    Q_UNUSED(locker);
    if (print) {
        QString msgStr = str;
        msgStr.prepend(OPCOLO_BOLD_RED);
        msgStr.append(OPCOLO_RESET);
        qCritical() << qUtf8Printable(msgStr);
    }
#ifdef CLUSTER_HAS_DLT
    DLT_LOG(dltCtx_, DLT_LOG_ERROR, DLT_STRING(str.toLocal8Bit()));
#else
    if (cache) {
        writeLog(str);
    }
#endif
}

void BootLog::printFatal(const QString& str, bool print, bool cache)
{
    QMutexLocker locker(&_logMutex);
    Q_UNUSED(locker);
    if (print) {
        QString msgStr = str;
        msgStr.prepend(OPCOLO_BOLD_WHITE);
        msgStr.prepend(OPCOLO_BACKGROUND_RED);
        msgStr.append(OPCOLO_RESET);
        qFatal(qUtf8Printable(msgStr), "%s");
    }
#ifdef CLUSTER_HAS_DLT
    DLT_LOG(dltCtx_, DLT_LOG_FATAL, DLT_STRING(str.toLocal8Bit()));
#else
    if (cache) {
        writeLog(str);
    }
#endif
}
