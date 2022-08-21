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

#include "bootprocess.h"
#include "bootlog.h"
#include "common/bootcommon.h"
#include <QCoreApplication>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QSharedMemory>
#include <QThread>
#include <QTimer>
#include <QTimerEvent>

#ifdef Q_OS_UNIX
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#endif

QString _BootLogStr(QStringLiteral(CLUSTER_LOG_STR));

class BootSandboxProcess : public QProcess {
public:
    explicit BootSandboxProcess(QObject* parent = nullptr)
        : QProcess(parent)
    {
    }
#if defined(Q_OS_UNIX) && QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
protected:
    void setupChildProcess()
    {
        ::chdir("/");
        ::setsid();
        ::umask(0);
    }
#endif
};

BootProcess::BootProcess(int index, const QString& filePath, const QVariantMap& configMap, QObject* parent)
    : QObject(parent)
    , m_index(index)
    , m_filePath(filePath)
{
    m_jsonName = QFileInfo(filePath).baseName();
    //
    m_exePath = configMap.value(QStringLiteral("exePath")).toString();
#ifdef Q_OS_WINDOWS
    if (m_exePath.toLower().endsWith(QStringLiteral(".exe"))) {
        m_exePath.chop(4);
    }
#endif
    m_baseName = QFileInfo(m_exePath).fileName();
    m_workDir = configMap.value(QStringLiteral("workDir")).toString();
    m_envList = configMap.value(QStringLiteral("envList")).toStringList();
    m_preCommands = configMap.value(QStringLiteral("preCommands")).toStringList();
    m_args = configMap.value(QStringLiteral("args")).toStringList();
    m_destroy = configMap.value(QStringLiteral("destroy"), false).toBool();
    m_order = configMap.value(QStringLiteral("order"), false).toBool();
    m_lock = configMap.value(QStringLiteral("lock"), false).toBool();
    m_daemon = configMap.value(QStringLiteral("daemon"), false).toBool();
    m_logVisible = configMap.value(QStringLiteral("logVisible"), false).toBool();
    m_logSave = configMap.value(QStringLiteral("logSave"), false).toBool();
    m_sleepTime = configMap.value(QStringLiteral("sleepTime"), 0).toInt();
    m_heartbeatTimes = configMap.value(QStringLiteral("heartbeatTimes")).toList();
    m_watch = configMap.value(QStringLiteral("watch"), false).toBool();
    m_clientShareMemAddress = configMap.value(QStringLiteral("clientShareMemAddress")).toString();
    //
    if (!m_exePath.isEmpty()) {
        m_hasExec = true;
        if (QFile::exists(qApp->applicationDirPath() + QStringLiteral("/") + m_exePath)) {
            m_exePath = qApp->applicationDirPath() + QStringLiteral("/") + m_exePath;
        }
#ifdef QT_DEBUG
#ifdef Q_OS_WINDOWS
        else if (QFile::exists(qApp->applicationDirPath() + QStringLiteral("/") + m_exePath + QStringLiteral("d.exe"))) {
            m_exePath = qApp->applicationDirPath() + QStringLiteral("/") + m_exePath + QStringLiteral("d.exe");
        }
#else
        else if (QFile::exists(qApp->applicationDirPath() + QStringLiteral("/") + m_exePath + QStringLiteral("d"))) {
            m_exePath = qApp->applicationDirPath() + QStringLiteral("/") + m_exePath + QStringLiteral("d");
        }
#endif
#else
#ifdef Q_OS_WINDOWS
        else if (QFile::exists(qApp->applicationDirPath() + QStringLiteral("/") + m_exePath + QStringLiteral(".exe"))) {
            m_exePath = qApp->applicationDirPath() + QStringLiteral("/") + m_exePath + QStringLiteral(".exe");
        }
#endif
#endif
    }
    for (QString command : qAsConst(m_preCommands)) {
        bool exec = true;
        command = command.trimmed();
        if (command.endsWith(QStringLiteral(" &"))) {
            command.chop(2);
            exec = false;
        }
        if (command.endsWith(QStringLiteral("&"))) {
            command.chop(1);
            exec = false;
        }
        QStringList clist = command.split(QStringLiteral(" "));
        if (clist.length() > 0) {
            QVariantMap varMap;
            varMap.insert(QStringLiteral("exePath"), clist.takeFirst());
            varMap.insert(QStringLiteral("exec"), exec);
            varMap.insert(QStringLiteral("args"), clist);
            m_prepareList.append(varMap);
        }
    }
    BootLog::printDebug(QString(QStringLiteral("<%1> Loading...")).arg(m_jsonName));
}

BootProcess::~BootProcess()
{
    stop();
    if (m_process) {
        delete m_process;
        m_process = nullptr;
    }
    for (QSharedMemory* shareMem : qAsConst(m_shareMemList)) {
        QMutexLocker locker(mutex());
        Q_UNUSED(locker);
        if (!shareMem) {
            continue;
        }
        if (shareMem->isAttached()) {
            shareMem->detach();
        }
        delete shareMem;
    }
    if (m_clientShareMem) {
        if (m_clientShareMem->isAttached()) {
            m_clientShareMem->detach();
        }
        delete m_clientShareMem;
    }

    m_memToHeartbeatTime.clear();
    clearHeartbeatTime();
    if (m_checkTimer) {
        delete m_checkTimer;
    }
    releaseCondition(true);
}

void BootProcess::prepare()
{
    if (m_hasPrepared) {
        return;
    }
    for (const QVariant& var : qAsConst(m_prepareList)) {
        const QVariantMap& varMap = var.toMap();
        QString exePath = varMap.value(QStringLiteral("exePath")).toString();
        bool exec = varMap.value(QStringLiteral("exec")).toBool();
        QStringList args = varMap.value(QStringLiteral("args")).toStringList();
        BootSandboxProcess* process = new BootSandboxProcess(0);
        m_prepareProcessList.append(process);
        process->setProcessChannelMode(QProcess::MergedChannels);
        if (m_logVisible || m_logSave) {
            connect(process, &QProcess::readyRead, this, [=]() {
                QString logStr;
                while (process->canReadLine()) {
                    logStr = getProcessLog(QString::fromLocal8Bit(process->readLine()));
                    BootLog::printInfo(exePath, logStr, m_logVisible, m_logSave);
                }
            });
            connect(process, static_cast<void (QProcess::*)(QProcess::ProcessError)>(&QProcess::errorOccurred), this, [=](QProcess::ProcessError error) {
                if (error == QProcess::UnknownError) {
                    return;
                }
                QString logStr = process->errorString();
                BootLog::printInfo(exePath, logStr, m_logVisible, m_logSave);
            });
        }
        process->start(exePath, args);
        if (process->state() != QProcess::NotRunning) {
            if (exec) {
                process->waitForStarted(-1);
                process->waitForFinished(-1);
            }
        }
    }
    m_hasPrepared = true;
}

void BootProcess::destroyPrepare()
{
    if (!m_hasPrepared) {
        return;
    }
    for (BootSandboxProcess* process : qAsConst(m_prepareProcessList)) {
        if (!process) {
            continue;
        }
        if (process->state() == QProcess::Running) {
            process->kill();
            process->waitForFinished(500);
        }
        delete process;
    }
    m_prepareProcessList.clear();
    m_hasPrepared = false;
}

void BootProcess::init()
{
    if (m_hasInit) {
        return;
    }
    createMem();
    initClientMem();
    if (!m_shareMemList.isEmpty()) {
        m_checkTimer = new QTimer(this);
        connect(m_checkTimer, &QTimer::timeout, this, &BootProcess::check);
    }
    if (m_hasExec) {
        m_process = new BootSandboxProcess(0);
#if defined(Q_OS_UNIX) && QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
        m_process->setChildProcessModifier([]() {
            ::chdir("/");
            ::setsid();
            ::umask(0);
        });
#endif
        connect(m_process, &QProcess::started, this, [=]() {
            QString logStr = getProcessLog(QStringLiteral("Started"));
            BootLog::printBootInfo(m_baseName, logStr, m_logVisible, m_logSave);
            m_processRunning = true;
            m_killFlags = false;
            if (m_checkTimer) {
                if (m_checkTimer->isActive() == false) {
                    m_checkTimer->start(100);
                }
            }
        });
        connect(m_process, static_cast<void (QProcess::*)(int, QProcess::ExitStatus)>(&QProcess::finished), this, [=](int exitCode, QProcess::ExitStatus exitStatus) {
            Q_UNUSED(exitStatus)
            QString logStr = getProcessLog(QStringLiteral("Finished (exit code = %1)").arg(QString::number(exitCode)));
            BootLog::printBootInfo(m_baseName, logStr, m_logVisible, m_logSave);
            releaseCondition(true);
            m_processRunning = false;
            clearHeartbeatTime();
            if (m_checkTimer) {
                m_checkTimer->stop();
            }
            if (m_stopFlags || m_killFlags) {
                return;
            }
            check();
        });
        if (m_logVisible || m_logSave) {
            connect(m_process, &QProcess::readyRead, this, [=]() {
                QString logStr;
                while (m_process->canReadLine()) {
                    logStr = getProcessLog(QString::fromLocal8Bit(m_process->readLine()));
                    if (logStr.startsWith(_BootLogStr)) {
                        logStr.remove(0, _BootLogStr.length());
                        BootLog::printBootInfo(m_baseName, logStr, m_logVisible, m_logSave);
                    } else {
                        BootLog::printInfo(m_baseName, logStr, m_logVisible, m_logSave);
                    }
                }
            });
            connect(m_process, static_cast<void (QProcess::*)(QProcess::ProcessError)>(&QProcess::errorOccurred), this, [=](QProcess::ProcessError error) {
                QString logStr = m_process->errorString();
                if (!m_stopFlags && !m_killFlags) {
                    BootLog::printInfo(m_baseName, logStr, m_logVisible, m_logSave);
                }
                if (error == QProcess::FailedToStart) {
                    m_stopFlags = true;
                    releaseCondition(true);
                    m_processRunning = false;
                    clearHeartbeatTime();
                    if (m_checkTimer) {
                        m_checkTimer->stop();
                    }
                }
            });
        }
        QStringList processEnvList = QProcess::systemEnvironment();
        processEnvList.append(m_envList);
        m_process->setProcessChannelMode(QProcess::MergedChannels);
        m_process->setEnvironment(processEnvList);
        m_process->setWorkingDirectory(m_workDir);
        if (m_order == true && m_lock == true) {
            QThread::yieldCurrentThread();
        }
        m_process->start(m_exePath, m_args);
    }
    m_processTime.start();
    //
    if (m_order == true) {
        if (m_sleepTime > 0) {
            QTimer::singleShot(m_sleepTime, Qt::CoarseTimer, this, [this]() {
                releaseCondition();
            });
        } else {
            releaseCondition();
        }
    }
    m_hasInit = true;
}

void BootProcess::createMem()
{
    if (m_daemon && m_hasExec && !m_heartbeatTimes.isEmpty()) {
        for (const QVariant& var : qAsConst(m_heartbeatTimes)) {
            const QVariantMap& varMap = var.toMap();
            if (varMap.isEmpty()) {
                continue;
            }
            const auto& varMapKeys = varMap.keys();
            if (varMapKeys.length() != 1) {
                continue;
            }
            QString key = varMapKeys.at(0);
            int heartbeatTime = varMap.value(key).toInt();
            if (heartbeatTime <= 0) {
                continue;
            }
            QString address = BOOT_HEARTBEAT_FSTR + m_jsonName + QStringLiteral("-") + key;
            QMutexLocker locker(mutex());
            Q_UNUSED(locker);
            QSharedMemory* shareMem = new QSharedMemory(this);
            shareMem->setKey(address);
#ifdef Q_OS_UNIX
            QSharedMemory removeMem;
            removeMem.setKey(address);
            if (removeMem.attach(QSharedMemory::ReadOnly) == true) {
                removeMem.detach();
            }
#endif
            if (shareMem->create(BOOT_SIZE, QSharedMemory::ReadWrite) == false) {
                BootLog::printCritical(QStringLiteral("Create memory error(key=%1)!").arg(shareMem->key()));
                continue;
            }
            if (BootCommon::clearMemory(shareMem) == false) {
                BootLog::printCritical(QStringLiteral("Create memory error(key=%1)!").arg(shareMem->key()));
            }
            m_shareMemList.append(shareMem);
            m_memToHeartbeatTime.insert(shareMem, heartbeatTime);
        }
    }
    if (m_hasExec && m_watch) {
        if (m_clientShareMem) {
            return;
        }
        m_clientShareMem = new QSharedMemory(this);
        m_clientShareMemAddress = BOOT_WATCH_FSTR + m_baseName;
        m_clientShareMem->setKey(m_clientShareMemAddress);
#ifdef Q_OS_UNIX
        QSharedMemory removeMem;
        removeMem.setKey(m_clientShareMemAddress);
        if (removeMem.attach(QSharedMemory::ReadOnly) == true) {
            removeMem.detach();
        }
#endif
        if (m_clientShareMem->create(BOOT_SIZE, QSharedMemory::ReadWrite) == false) {
            BootLog::printCritical(QStringLiteral("Create merory error(key=%1)!").arg(m_clientShareMem->key()));
            return;
        }
        if (BootCommon::clearMemory(m_clientShareMem) == false) {
            BootLog::printCritical(QStringLiteral("Create memory error(key=%1)!").arg(m_clientShareMem->key()));
        }
    }
}

void BootProcess::initClientMem()
{
    if (m_clientShareMem) {
        if (m_clientShareMem->isAttached()) {
            if (BootCommon::writeMemory(m_clientShareMem, BootCommon::UNKNOWN, QVariant(), true) == false) {
                BootLog::printCritical(QStringLiteral("Init Memory error (key=%1)!").arg(m_clientShareMem->key()));
            }
        }
    }
}

void BootProcess::initHeartbeatMem()
{
    for (QSharedMemory* shareMem : qAsConst(m_shareMemList)) {
        if (shareMem->isAttached()) {
            QMutexLocker locker(mutex());
            Q_UNUSED(locker);
            if (BootCommon::writeMemory(shareMem, BootCommon::UNKNOWN, QVariant(), true) == false) {
                BootLog::printCritical(QStringLiteral("Init Memory error (key=%1)!").arg(shareMem->key()));
                continue;
            }
        }
    }
}

void BootProcess::stop()
{
    if (!m_hasExec) {
        return;
    }
    m_stopFlags = true;
    m_restartTimes = 0;
    kill();
}

void BootProcess::start()
{
    if (!m_hasExec) {
        return;
    }
    m_restartTimes = 0;
    m_stopFlags = true;
    restart();
    m_restartTimes = 0;
    m_processTime.restart();
    m_stopFlags = false;
    m_killFlags = false;
}

void BootProcess::check()
{
    if (!m_hasInit) {
        return;
    }
    if (m_stopFlags || m_killFlags) {
        return;
    }
    if (!m_daemon || !m_hasExec) {
        return;
    }
    if (!m_process) {
        return;
    }
    if (m_process->state() == QProcess::NotRunning) {
        m_processRunning = false;
        restart();
        return;
    }
    // heart
    if (m_checkHeartbeat == false) {
        return;
    }
    bool heartbeat_restart = false;
    int heartbeatTime = -1;
    for (QSharedMemory* shareMem : qAsConst(m_shareMemList)) {
        QMutexLocker locker(mutex());
        Q_UNUSED(locker);
        if (!shareMem) {
            continue;
        }
        if (shareMem->isAttached() == false) {
            continue;
        }
        if (m_memToTime.isEmpty()) {
            continue;
        }
        quint64 time = BootCommon::getCurrentTimeMs();
        quint64 lastTime = m_memToTime.value(shareMem);
        if (time <= 0 || lastTime <= 0) {
            // BootLog::printCritical(QStringLiteral("<%1> Get time error").arg(m_jsonName));
            continue;
        }
        heartbeatTime = m_memToHeartbeatTime.value(shareMem);
        if (heartbeatTime <= 0) {
            // BootLog::printCritical(QStringLiteral("<%1> Get heartbeat time error").arg(m_jsonName));
            continue;
        }
        if (time - lastTime > heartbeatTime) {
            heartbeat_restart = true;
            BootLog::printCritical(QStringLiteral("<%1> Heartbeat time out! (%2)").arg(m_jsonName, shareMem->key()));
            BootLog::printWarning(QStringLiteral("<%1> Current time = %2, Last time = %3").arg(m_jsonName, QString::number(time), QString::number(lastTime)));
            break;
        }
    }
    if (heartbeat_restart) {
        restart();
    }
}

void BootProcess::writeToClientMem(const QString& command)
{
    if (!m_clientShareMem) {
        return;
    }
    if (!m_clientShareMem->isAttached()) {
        return;
    }
    bool ok = BootCommon::writeMemory(m_clientShareMem, BootCommon::SINGLE_COMMAND, command);
    if (ok) {
        ok = BootCommon::releaseSemaphore(m_clientShareMem->key());
    }
    if (ok == false) {
        BootLog::printCritical(QStringLiteral("Write Memory error (key=%1)!").arg(m_clientShareMem->key()));
    }
}

void BootProcess::dealHeartbeat(QSharedMemory* shareMem, qint64 time)
{
    QMutexLocker locker(mutex());
    Q_UNUSED(locker);
    if (m_memToTime.value(shareMem) != time) {
        m_checkHeartbeat = true;
        m_memToTime.insert(shareMem, time);
    }
}

void BootProcess::waitCondition(bool useLock)
{
    if (m_order == true) {
        if (useLock == true && m_lock == true) {
            BootCommon::waitSemaphore(BOOT_LOCK__FSTR + m_baseName);
        }
        m_semaphore.acquire(0);
    }
}

void BootProcess::releaseCondition(bool useLock)
{
    if (m_order == true) {
        m_semaphore.release(1);
        if (useLock == true && m_lock == true) {
            BootCommon::releaseSemaphore(BOOT_LOCK__FSTR + m_baseName);
        }
    }
}

QList<QSharedMemory*> BootProcess::getShareMemList() const
{
    return m_shareMemList;
}

bool BootProcess::isDestroyType() const
{
    return m_destroy;
}

bool BootProcess::isRunning() const
{
    return m_processRunning;
}

bool BootProcess::isDaemon() const
{
    return m_daemon;
}

bool BootProcess::hasClientMem() const
{
    if (!m_clientShareMem) {
        return false;
    }
    return m_clientShareMem->isAttached();
}

bool BootProcess::hasExec() const
{
    return m_hasExec;
}

bool BootProcess::hasInit() const
{
    return m_hasInit;
}

QString BootProcess::filePath() const
{
    return m_filePath;
}

QString BootProcess::jsonName() const
{
    return m_jsonName;
}

QString BootProcess::baseName() const
{
    return m_baseName;
}

QMutex* BootProcess::mutex()
{
    return &m_mutex;
}

void BootProcess::kill()
{
    if (!m_hasExec) {
        return;
    }
    if (!m_process) {
        return;
    }
    m_killFlags = true;
    if (m_process->state() == QProcess::Running) {
        if (m_clientShareMem) {
            if (m_clientShareMem->isAttached()) {
                writeToClientMem(QStringLiteral(CLUSTER_CLOSESIG_STR));
                m_process->waitForFinished(100);
            }
        }
        if (m_process->state() == QProcess::Running) {
            m_process->kill();
            m_process->waitForFinished(500);
        }
    }
#ifdef Q_OS_WINDOWS
    if (!m_baseName.isEmpty()) {
        QString killName = m_baseName + QStringLiteral(".exe");
        QProcess killProcess;
        killProcess.start(QStringLiteral("cmd.exe"), QStringList() << QStringLiteral("/c") << QStringLiteral("taskkill") << QStringLiteral("-f") << QStringLiteral("-im") << killName);
        killProcess.waitForStarted(500);
        killProcess.waitForFinished(500);
    }
#elif defined(Q_OS_LINUX)
    if (!m_baseName.isEmpty()) {
        QString killName = m_baseName;
        system(QStringLiteral("killall -q -9 %1 >/dev/null 2>&1").arg(killName).toLocal8Bit());
    }
#elif defined(Q_OS_QNX)
    if (!m_baseName.isEmpty()) {
        QString killName = m_baseName;
        system(QStringLiteral("pkill -q -9 %1 >/dev/null 2>&1").arg(killName).toLocal8Bit());
        // system(QStringLiteral("kill -9 $(pidin arg | grep %1 | grep -v 'grep' |  awk '{print $1}') > /dev/null 2>&1").arg(m_baseName).toUtf8());
    }
#endif
    m_checkHeartbeat = false;
    m_processRunning = false;
    clearHeartbeatTime();
}

void BootProcess::restart()
{
    if (!m_process) {
        return;
    }
    m_restartTimes++;
    if (m_stopFlags == false) {
        BootLog::printWarning(QStringLiteral("<%1> Restart times = ").arg(m_jsonName) + QString::number(m_restartTimes));
    }
    if (m_restartTimes >= 5 && m_processTime.elapsed() < 20000) {
        BootLog::printWarning(QStringLiteral("<%1> Can not start!").arg(m_jsonName));
        m_stopFlags = true;
        return;
    }
    if (m_restartTimes >= 50) {
        BootLog::printWarning(QStringLiteral("<%1> Restart times is too much!").arg(m_jsonName));
        m_stopFlags = true;
        return;
    }
    kill();
    initClientMem();
    m_process->start(m_exePath, m_args);
    m_process->waitForStarted(500);
}

void BootProcess::clearHeartbeatTime()
{
    QMutexLocker locker(mutex());
    Q_UNUSED(locker);
    m_checkHeartbeat = false;
    m_memToTime.clear();
}

QString BootProcess::getProcessLog(const QString& log)
{
    QString processLog = log;
    processLog.replace(QStringLiteral("\r\n"), QStringLiteral("\n"));
    if (processLog.endsWith(QStringLiteral("\n"))) {
        processLog.chop(1);
    }
    return processLog;
}
