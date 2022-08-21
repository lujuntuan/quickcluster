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

#ifndef BOOT_PROCESS_H
#define BOOT_PROCESS_H

#include <QElapsedTimer>
#include <QHash>
#include <QMutex>
#include <QObject>
#include <QSemaphore>
#include <QVariantMap>

class QSharedMemory;
class BootSandboxProcess;
class QTimer;

class BootProcess : public QObject {
    Q_OBJECT
public:
    explicit BootProcess(int index, const QString& filePath, const QVariantMap& configMap, QObject* parent = nullptr);
    ~BootProcess();

public:
    void prepare();
    void destroyPrepare();

public slots:
    void init();
    void createMem();
    void initClientMem();
    void initHeartbeatMem();
    void stop();
    void start();
    void check();
    void writeToClientMem(const QString& command);
    void dealHeartbeat(QSharedMemory* shareMem, qint64 time);
    void waitCondition(bool useLock = false);
    void releaseCondition(bool useLock = false);

public:
    QList<QSharedMemory*> getShareMemList() const;
    bool isDestroyType() const;
    bool isLocked() const;
    bool isRunning() const;
    bool isDaemon() const;
    bool hasClientMem() const;
    bool hasExec() const;
    bool hasInit() const;
    QString filePath() const;
    QString jsonName() const;
    QString baseName() const;
    QMutex* mutex();

private:
    void kill();
    void restart();
    void clearHeartbeatTime();
    QString getProcessLog(const QString& log);

private:
    bool m_destroy = false;
    bool m_order = false;
    bool m_lock = false;
    bool m_daemon = false;
    bool m_logVisible = false;
    bool m_logSave = false;
    bool m_watch = false;
    bool m_checkHeartbeat = false;
    bool m_hasExec = false;
    bool m_hasInit = false;
    bool m_stopFlags = false;
    bool m_killFlags = false;
    bool m_hasPrepared = false;
    bool m_processRunning = false;
    int m_index = 0;
    int m_sleepTime = 0;
    int m_restartTimes = 0;
    BootSandboxProcess* m_process = nullptr;
    QSharedMemory* m_clientShareMem = nullptr;
    QTimer* m_checkTimer = nullptr;
    QString m_filePath;
    QString m_jsonName;
    QString m_exePath;
    QString m_workDir;
    QString m_clientShareMemAddress;
    QString m_baseName;
    QStringList m_envList;
    QStringList m_preCommands;
    QStringList m_args;
    QVariantList m_heartbeatTimes;
    QVariantList m_prepareList;
    QElapsedTimer m_processTime;
    QMutex m_mutex;
    QSemaphore m_semaphore;
    QList<BootSandboxProcess*> m_prepareProcessList;
    QList<QSharedMemory*> m_shareMemList;
    QHash<QSharedMemory*, int> m_memToHeartbeatTime;
    QHash<QSharedMemory*, qint64> m_memToTime;
};

#endif // BOOT_PROCESS_H
