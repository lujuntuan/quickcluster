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

#ifndef CLUSTER_SERVER_BASE_H
#define CLUSTER_SERVER_BASE_H

#include "clusterexport.h"
#include "clustersingleton.h"
#include <QDebug>
#include <QRemoteObjectHost>

class QTimer;
typedef void (*boot_daemon_callback_t)(const char* command, void* ptr);

class CLUSTER_EXPORT ClusterServerBase {
public:
    ClusterServerBase();
    ~ClusterServerBase();
    void create(void* targetPtr, boot_daemon_callback_t fun);
    void destroy(QObject* sourceObj);
    void initialize(QObject* sourceObj, const QString& nodeName, const QUrl& url);
    void reconnect();
    void finished();
    void printConnected(bool connected);
    void quit();
    QRemoteObjectHost* hostObject();
    QString hostName();

private:
    bool m_hasCreate = false;
    bool m_hasConnect = false;
    QObject* m_sourceObj = nullptr;
    QRemoteObjectHost* m_hostObject = nullptr;
    QTimer* m_reconnectTimer = nullptr;
    QString m_nodeName;
    QString m_appName;
    QString m_heartbeatName;
    QUrl m_url;
};

template <class T>
class ClusterServerProxy : public ClusterSingleton<ClusterServerProxy<T>> {
public:
    ClusterServerProxy()
    {
        if (ClusterServerProxy::getInstance()) {
            qFatal("class SourceBase Must be singleton mode");
        }
        ClusterServerProxy::setInstance(this);
        m_base.create(this, watchServiceCommand);
        T* sourcePtr = static_cast<T*>(this);
        if (sourcePtr) {
            if (T::staticMetaObject.indexOfMethod("connected") >= 0) {
                QObject::connect(sourcePtr, &T::connectedChanged, [&](bool connected) {
                    m_base.printConnected(connected);
                });
            }
        }
    }
    virtual ~ClusterServerProxy()
    {
        T* sourcePtr = static_cast<T*>(this);
        if (sourcePtr) {
            m_base.destroy(sourcePtr);
        }
    }
    void initialize(const QUrl url = QUrl())
    {
        T* sourcePtr = static_cast<T*>(this);
        if (sourcePtr) {
            int index = T::staticMetaObject.indexOfClassInfo(QCLASSINFO_REMOTEOBJECT_TYPE);
            if (index < 0) {
                qFatal("Can not find QCLASSINFO_REMOTEOBJECT_TYPE");
                return;
            }
            m_base.initialize(sourcePtr, T::staticMetaObject.classInfo(index).value(), url);
            registerCallback();
            m_base.finished();
        }
    }
    QRemoteObjectHost* hostObject()
    {
        return m_base.hostObject();
    }
    QString hostName()
    {
        return m_base.hostName();
    }

public:
    virtual void registerCallback()
    {
    }
    virtual void receiveClientCommand(const QString& command)
    {
        T* sourcePtr = static_cast<T*>(this);
        if (sourcePtr) {
            emit sourcePtr->commandChanged(command);
        }
    }

private:
    static void watchServiceCommand(const char* command, void* ptr)
    {
        QString commandStr = command;
        if (commandStr == QStringLiteral(CLUSTER_CLOSESIG_STR)) {
            ClusterServerProxy::getInstance()->m_base.quit();
            return;
        }
        ClusterServerProxy* sourceBase = static_cast<ClusterServerProxy*>(ptr);
        if (sourceBase) {
            sourceBase->receiveClientCommand(commandStr);
        }
    }

private:
    ClusterServerBase m_base;
};

#endif // CLUSTER_SERVER_BASE_H
