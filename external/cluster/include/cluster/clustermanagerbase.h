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

#ifndef CLUSTER_MANAGERBASE_H
#define CLUSTER_MANAGERBASE_H

#include "clusterexport.h"
#include "clustersingleton.h"
#include <QDebug>
#include <QDir>
#include <QElapsedTimer>
#include <QQmlEngine>
#include <QQuickView>
#include <QRemoteObjectNode>
#include <QSemaphore>
#include <QUrl>

class ClusterReplica;

class CLUSTER_EXPORT ClusterManagerBase : public QObject, public ClusterSingleton<ClusterManagerBase> {
    Q_OBJECT
    Q_PROPERTY(QQuickView* view READ view CONSTANT)
    Q_PROPERTY(int fps READ fps NOTIFY fpsChanged)
    Q_PROPERTY(bool fpsVisible READ fpsVisible WRITE setFpsVisible NOTIFY fpsVisibleChanged)
    Q_PROPERTY(QString skin READ skin WRITE setSkin NOTIFY skinChanged)
    Q_PROPERTY(QStringList skinList READ skinList NOTIFY skinListChanged)
    Q_PROPERTY(QString impPath READ impPath NOTIFY impPathChanged)
    Q_PROPERTY(QString impSkinPath READ impSkinPath NOTIFY impSkinPathChanged)
    Q_PROPERTY(QString currentPath READ currentPath CONSTANT)
    Q_PROPERTY(QString configPath READ configPath CONSTANT)
    Q_PROPERTY(QString docPath READ docPath CONSTANT)
    Q_PROPERTY(QString tmpPath READ tmpPath CONSTANT)
    Q_PROPERTY(QString platformDocPath READ platformDocPath CONSTANT)
public:
    explicit ClusterManagerBase(QObject* parent = nullptr);
    virtual ~ClusterManagerBase();
    static void waitForScreen();
    void initialize(QUrl source = QUrl(), bool cacheImage = true);
    template <class T>
    auto getReplica(const QUrl& url = QUrl())
    {
        class ClusterTargetReplica : public T, public ClusterSingleton<ClusterTargetReplica> {
            using T::T;
            friend class QRemoteObjectNode;
        };
        if (ClusterTargetReplica::getInstance()) {
            return ClusterTargetReplica::getInstance();
        }
        int index = ClusterTargetReplica::staticMetaObject.indexOfClassInfo(QCLASSINFO_REMOTEOBJECT_TYPE);
        if (index < 0) {
            qFatal("Can not find QCLASSINFO_REMOTEOBJECT_TYPE");
            return (ClusterTargetReplica*)nullptr;
        }
        QRemoteObjectNode* node = new QRemoteObjectNode(this);
        ClusterTargetReplica* replica = node->acquire<ClusterTargetReplica>();
        initReplica(node, replica, ClusterTargetReplica::staticMetaObject.classInfo(index).value(), url);
        ClusterTargetReplica::setInstance(replica);
        return ClusterTargetReplica::getInstance();
    }
    bool loadSkinPlugins(const QString& skinName);

public slots:
    bool makePath(const QString& path);
    bool removePath(const QString& path);
    bool fileExists(const QString& filePath);
    QVariant readJson(const QString& filePath);
    bool saveJson(const QVariant& data, const QString& filePath);
    bool cleanCache();

public:
    void show();
    //
    QQuickView* view() const;
    int fps() const;
    bool fpsVisible() const;
    void setFpsVisible(bool fpsVisible);
    QString skin() const;
    void setSkin(const QString& skin);
    QStringList skinList() const;
    QString impPath() const;
    QString impSkinPath() const;
    QString currentPath() const;
    QString configPath() const;
    QString docPath() const;
    QString tmpPath() const;
    QString platformDocPath() const;

public:
    virtual void installPlugins() {};
    virtual void installReplicas() = 0;
    virtual void receiveClientCommand(const QString& command);

private:
    void initView();
    void initSkin();
    void initReplica(QRemoteObjectNode* node, QRemoteObjectReplica* replica, const QString& nodeName, const QUrl& url);
    void configFps();

private:
    bool m_fpsVisible = true;
    int m_fps = 0;
    int m_frameSwappedCount = 0;
    QQuickView* m_view = nullptr;
    QString m_appName;
    QString m_heartbeatName;
    QString m_skin;
    QString m_impPath;
    QString m_impSkinPath;
    QStringList m_skinList;
    QElapsedTimer m_frameSwappedTime;

signals:
    void commandChanged(const QString& command);
    void fpsChanged();
    void fpsVisibleChanged();
    void skinChanged();
    void skinListChanged();
    void impPathChanged();
    void impSkinPathChanged();
};

#endif // CLUSTER_MANAGERBASE_H
