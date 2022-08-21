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

#include "bootmanager/bootdaemon.h"
#include "common/bootcommon.h"
#include <QCoreApplication>
#include <QDebug>
#include <QHash>
#include <QMutex>
#include <QMutexLocker>
#include <QSharedMemory>
#include <QThread>

class Heartbeat {
public:
    explicit Heartbeat(const QString& name)
        : m_name(name)
    {
    }
    ~Heartbeat()
    {
    }
    int create()
    {
        QString address = BOOT_HEARTBEAT_FSTR + m_name;
        m_shareMem.setKey(address);
        if (m_shareMem.attach(QSharedMemory::ReadWrite) == false) {
            return -10;
        }
        return 0;
    }
    int send()
    {
        if (!m_shareMem.isAttached()) {
            return -10;
        }
        bool ok = BootCommon::writeMemory(&m_shareMem, BootCommon::HEARDBEAT);
        if (ok) {
            ok = BootCommon::releaseSemaphore(BOOT_CTRLKEY_FSTR);
        }
        if (ok == false) {
            BootCommon::writeMemory(&m_shareMem, BootCommon::HEARDBEAT, QVariant(), true);
            return -11;
        }
        return 0;
    }
    int destroy()
    {
        if (!m_shareMem.isAttached()) {
            return -10;
        }
        m_shareMem.detach();
        return 0;
    }

private:
    QString m_name;
    QSharedMemory m_shareMem;
};

static bool _isQtMainLoop = false;

class WatchThread : public QThread {
public:
    explicit WatchThread(const QString& shareMemAddress, boot_daemon_callback_t bootDaemonFun, void* ptr = 0, QObject* parent = 0)
        : QThread(parent)
        , _shareMemAddress(shareMemAddress)
        , _bootDaemonFun(bootDaemonFun)
        , _ptr(ptr)
    {
    }

public:
    int init()
    {
        if (_shareMemAddress.isEmpty()) {
            return -5;
        }
        if (!_bootDaemonFun) {
            return -6;
        }
        _shareMem.setKey(_shareMemAddress);
        if (_shareMem.attach(QSharedMemory::ReadWrite) == false) {
            return -10;
        }
        return 0;
    }

protected:
    void run() override
    {
        if (_shareMemAddress.isEmpty()) {
            return;
        }
        if (!_bootDaemonFun) {
            return;
        }
        if (!_shareMem.isAttached()) {
            return;
        }
        qint64 time;
        int type;
        QVariant content;
        for (;;) {
            if (_shareMem.isAttached() == false) {
                break;
            }
            if (this->isInterruptionRequested() == true) {
                break;
            }
            BootCommon::waitSemaphore(_shareMem.key());
            if (BootCommon::readMemory(&_shareMem, &type, &content, &time) == false) {
                continue;
            }
            if (type != BootCommon::SINGLE_COMMAND) {
                continue;
            }
            if (!content.isValid()) {
                continue;
            }
            if (time == _time) {
                continue;
            }
            _time = time;
            if (_isQtMainLoop) {
                QMetaObject::invokeMethod(this, "objectNameChanged", Qt::QueuedConnection, Q_ARG(QString, content.toString()));
            } else {
                QByteArray byteArray = content.toString().toLocal8Bit();
                const char* msg = byteArray.constData();
                if (_bootDaemonFun) {
                    _bootDaemonFun(msg, _ptr);
                }
            }
        }
    }

public:
    QString _shareMemAddress;
    boot_daemon_callback_t _bootDaemonFun;
    void* _ptr;
    QSharedMemory _shareMem;
    qint64 _time;
};

QHash<QString, Heartbeat*> _heartbeatToMem;
WatchThread* _watchThread = 0;
QMutex _heartbeatMutex;
QMutex _watchMutex;

int boot_create_heartbeat(const char* name)
{
    QMutexLocker locker(&_heartbeatMutex);
    if (_heartbeatToMem.contains(name)) {
        return -2;
    }
    Heartbeat* heartbeat = new Heartbeat(name);
    _heartbeatToMem.insert(name, heartbeat);
    return heartbeat->create();
}

int boot_send_heartbeat(const char* name)
{
    QMutexLocker locker(&_heartbeatMutex);
    Heartbeat* heartbeat = _heartbeatToMem.value(name);
    if (!heartbeat) {
        return -2;
    }
    return heartbeat->send();
}

int boot_remove_heartbeat(const char* name)
{
    QMutexLocker locker(&_heartbeatMutex);
    Heartbeat* heartbeat = _heartbeatToMem.value(name);
    if (!heartbeat) {
        return -2;
    }
    int reval = heartbeat->destroy();
    _heartbeatToMem.remove(name);
    delete heartbeat;
    return reval;
}

int boot_create_bootwatch(const char* name, boot_daemon_callback_t fun, void* ptr)
{
    QMutexLocker locker(&_watchMutex);
    if (_watchThread) {
        return -2;
    }
    QString appName = QString(name);
    if (appName.isEmpty()) {
        return -3;
    }
    QString watchName = BOOT_WATCH_FSTR + appName;
    _watchThread = new WatchThread(watchName, fun, ptr);
    int reval = _watchThread->init();
    if (reval != 0) {
        delete _watchThread;
        _watchThread = 0;
        return reval;
    }
    _watchThread->start();
    return 0;
}

int boot_create_bootwatch_inqtloop(const char* name, boot_daemon_callback_t fun, void* ptr)
{
    if (_watchThread) {
        return -2;
    }
    if (!qApp) {
        return -3;
    }
    if (qApp->thread() != QThread::currentThread()) {
        return -20;
    }
    _isQtMainLoop = true;
    int reval = boot_create_bootwatch(name, fun, ptr);
    if (reval != 0) {
        _isQtMainLoop = false;
        return reval;
    }
    QObject::connect(_watchThread, &WatchThread::objectNameChanged, [](const QString& objectName) {
        QByteArray byteArray = objectName.toLocal8Bit();
        const char* msg = byteArray.constData();
        if (_watchThread->_bootDaemonFun) {
            _watchThread->_bootDaemonFun(msg, _watchThread->_ptr);
        }
    });
    return 0;
}

int boot_remove_bootwatch(const char* name)
{
    QMutexLocker locker(&_watchMutex);
    if (!_watchThread) {
        return -2;
    }
    if (!_watchThread->isRunning()) {
        return -3;
    }
    if (_watchThread->_shareMemAddress != name) {
        return -4;
    }
    BootCommon::releaseSemaphore(_watchThread->_shareMem.key());
    _watchThread->requestInterruption();
    _watchThread->quit();
    _watchThread->wait();
    delete _watchThread;
    _watchThread = 0;
    _isQtMainLoop = false;
    return 0;
}

int boot_unlock(const char* name)
{
    QString appName = QString(name);
    if (appName.isEmpty()) {
        return -1;
    }
    QThread::yieldCurrentThread();
    if (BootCommon::releaseSemaphore(BOOT_LOCK__FSTR + appName) == true) {
        return 0;
    } else {
        return -2;
    }
}
