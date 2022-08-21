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

#include "cluster/clustermanagerbase.h"
#include "cluster/clusterheartbeat.h"
#include "cluster/clusterlog.h"
#include "clusterdaemon.h"
#include "clusterimageprovider.h"
#include <QDir>
#include <QFile>
#include <QGuiApplication>
#include <QJsonDocument>
#include <QLibrary>
#include <QObject>
#include <QQmlContext>
#include <QQmlEngine>
#include <QStandardPaths>
#include <future>

#ifdef Q_OS_QNX
#include <libgen.h>
#endif
#ifdef Q_OS_UNIX
#include <unistd.h>
#endif

#ifdef CLUSTER_HAS_BOOT_DAEMON
#include <bootmanager/bootdaemon.h>

static void watchClientCommand(const char* command, void* ptr)
{
    QString commandStr = command;
    ClusterManagerBase* managerBase = static_cast<ClusterManagerBase*>(ptr);
    if (managerBase) {
        if (commandStr == QStringLiteral(CLUSTER_CLOSESIG_STR)) {
            if (managerBase->view()) {
                managerBase->view()->close();
            }
            return;
        } else if (commandStr == "clean") {
            if (managerBase) {
                managerBase->cleanCache();
            }
        }
        managerBase->receiveClientCommand(commandStr);
    }
}
#endif

ClusterManagerBase::ClusterManagerBase(QObject* parent)
    : QObject(parent)
{
    if (ClusterManagerBase::getInstance()) {
        qFatal("class ClusterManagerBase Must be singleton mode");
    }
    ClusterManagerBase::setInstance(this);
    ClusterDaemon::initialize();
    m_appName = qApp->applicationName();
#ifdef QT_DEBUG
    if (m_appName.endsWith(QStringLiteral("d"))) {
        m_appName.chop(1);
    }
#endif
    m_heartbeatName = m_appName + QStringLiteral("-main");
#ifdef CLUSTER_HAS_BOOT_DAEMON
    int reval = boot_create_bootwatch_inqtloop(m_appName.toUtf8(), watchClientCommand, this);
    if (reval == 0) {
        qDebug() << qUtf8Printable(QStringLiteral("Control channel created successfully."));
    }
#endif
}

ClusterManagerBase::~ClusterManagerBase()
{
    if (m_view) {
        delete m_view;
    }
#ifdef CLUSTER_HAS_BOOT_DAEMON
    boot_remove_bootwatch(m_appName.toUtf8());
#endif
}

void ClusterManagerBase::waitForScreen()
{
#ifdef Q_OS_QNX
    waitfor("/dev/screen", 3000, 10);
#endif
}

void ClusterManagerBase::initialize(QUrl source, bool cacheImage)
{
    if (m_view) {
        qWarning() << qUtf8Printable("ClusterManagerBase has initialized!");
        return;
    }
    std::future<void> pluginsFuture = std::async(std::launch::async, [this]() {
        installPlugins();
    });
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
    initView();
    if (cacheImage) {
        m_impPath = QStringLiteral("image://") + ClusterImageProvider::getPrefixName();
        m_view->engine()->addImageProvider(ClusterImageProvider::getPrefixName(), new ClusterImageProvider);
    }
    initSkin();
    pluginsFuture.get();
    m_view->setSource(source);
#ifdef CLUSTER_HAS_BOOT_DAEMON
    ClusterHeartbeat::create(m_heartbeatName, CLUSTER_HEARTBEART_INTERVAL, this);
#endif
    ClusterLog::printToBoot(QStringLiteral("Inited"));
    m_frameSwappedTime.restart();
}

bool ClusterManagerBase::loadSkinPlugins(const QString& skinName)
{
    QDir skinDir(QStringLiteral("/usr/lib64/cluster-skins/"));
    if (!skinDir.exists() || skinDir.isEmpty()) {
        skinDir.setPath(QStringLiteral("/usr/lib/cluster-skins/"));
        if (!skinDir.exists() || skinDir.isEmpty()) {
            skinDir.setPath(QStringLiteral("../lib64/cluster-skins/"));
            if (!skinDir.exists() || skinDir.isEmpty()) {
                skinDir.setPath(QStringLiteral("../lib/cluster-skins/"));
                if (!skinDir.exists() || skinDir.isEmpty()) {
                    skinDir.setPath(QStringLiteral("../cluster-skins/"));
                    if (!skinDir.exists() || skinDir.isEmpty()) {
                        skinDir.setPath(QStringLiteral("./cluster-skins/"));
                        if (!skinDir.exists() || skinDir.isEmpty()) {
                            qWarning() << qUtf8Printable(QStringLiteral("Not exists skin resource!"));
                            return false;
                        }
                    }
                }
            }
        }
    }
    QStringList skinList;
    QString checkName;
    QStringList nameFilters;
    QString splitStr = QStringLiteral("-");
#ifdef Q_OS_WINDOWS
    checkName = skinName + splitStr;
    nameFilters << QStringLiteral("*.dll");
#elif defined(Q_OS_UNIX)
    checkName = skinName + splitStr;
    nameFilters << QStringLiteral("*.so");
#endif
    const auto& entryInfoList = skinDir.entryInfoList(nameFilters, QDir::Files | QDir::NoDotAndDotDot);
    for (const QFileInfo& fileInfo : entryInfoList) {
        if (!fileInfo.baseName().startsWith(checkName)) {
            continue;
        }
        QLibrary skinLib(fileInfo.filePath());
        bool ok = skinLib.load();
        if (ok == true) {
            QString skinName = fileInfo.baseName();
            if (skinName.startsWith(QStringLiteral("lib"))) {
                skinName = skinName.mid(3, skinName.length() - 3);
            }
            QString skinTypeName = skinName;
            int d = skinTypeName.lastIndexOf(splitStr);
            if (d >= 0 && d < skinTypeName.length() - 1) {
                skinTypeName = skinTypeName.mid(d + 1, skinTypeName.length() - (d + 1));
                skinList.append(skinTypeName);
                // qDebug() << qUtf8Printable(QStringLiteral("Load %1 succeed !").arg(fileInfo.fileName()));
            } else {
                qWarning() << qUtf8Printable(QStringLiteral("Load %1 error !(%2)").arg(fileInfo.fileName(), skinLib.errorString()));
            }
        } else {
            qWarning() << qUtf8Printable(QStringLiteral("Load %1 error !(%2)").arg(fileInfo.fileName(), skinLib.errorString()));
        }
    }
    //
    if (!skinList.isEmpty()) {
        m_skinList = skinList;
        emit skinListChanged();
    }
    return true;
}

bool ClusterManagerBase::makePath(const QString& path)
{
    QDir dir(path);
    return dir.mkpath(path);
}

bool ClusterManagerBase::removePath(const QString& path)
{
    QDir dir(path);
    return dir.removeRecursively();
}

bool ClusterManagerBase::fileExists(const QString& filePath)
{
    return QFile::exists(filePath);
}

QVariant ClusterManagerBase::readJson(const QString& filePath)
{
    QFile file(filePath);
    if (!file.exists()) {
        qWarning() << qUtf8Printable(QStringLiteral("ReadJson error !(File not exists)"));
        return QVariant();
    }
    if (!file.open(QFile::ReadOnly | QFile::Text)) {
        file.close();
        qWarning() << qUtf8Printable(QStringLiteral("ReadJson error !(File open error)"));
        return QVariant();
    }
    QByteArray byteArray = file.readAll();
    file.close();
    QJsonParseError jsonError;
    QJsonDocument doc = QJsonDocument::fromJson(byteArray, &jsonError);
    if (jsonError.error != QJsonParseError::NoError) {
        qWarning() << qUtf8Printable(QStringLiteral("ReadJson error !(%1)").arg(jsonError.errorString()));
        return QVariant();
    }
    QVariant var = doc.toVariant();
    if (!var.isValid()) {
        qWarning() << qUtf8Printable(QStringLiteral("ReadJson error !(%1)").arg("Empty value"));
        return QVariant();
    }
    return var;
}

bool ClusterManagerBase::saveJson(const QVariant& data, const QString& filePath)
{
    QVariantMap varMap = data.toMap();
    QJsonDocument doc;
    if (!varMap.isEmpty()) {
        doc = QJsonDocument::fromVariant(varMap);
    } else {
        doc = QJsonDocument::fromVariant(data.toList());
    }
    if (doc.isEmpty()) {
        qWarning() << qUtf8Printable(QStringLiteral("SaveJson error !(Empty value)"));
        return false;
    }
    QByteArray byteArray = doc.toJson();
    if (byteArray.isEmpty()) {
        qWarning() << qUtf8Printable(QStringLiteral("SaveJson error !(Empty json)"));
        return false;
    }
    QDir dir = QFileInfo(filePath).dir();
    if (!dir.exists()) {
        dir.mkpath(dir.path());
    }
    QFile file(filePath);
    if (!file.open(QFile::WriteOnly | QFile::Text | QFile::Truncate)) {
        file.close();
        qWarning() << qUtf8Printable(QStringLiteral("SaveJson error !(File open error)"));
        return false;
    }
    file.write(byteArray);
    file.close();
#ifdef Q_OS_UNIX
    ::sync();
#endif
    return true;
}

bool ClusterManagerBase::cleanCache()
{
    QDir dir(QStandardPaths::writableLocation(QStandardPaths::CacheLocation));
    return dir.removeRecursively();
}

QQuickView* ClusterManagerBase::view() const
{
    return m_view;
}

void ClusterManagerBase::show()
{
    m_view->show();
}

int ClusterManagerBase::fps() const
{
    return m_fps;
}

bool ClusterManagerBase::fpsVisible() const
{
    return m_fpsVisible;
}

void ClusterManagerBase::setFpsVisible(bool fpsVisible)
{
    if (m_fpsVisible != fpsVisible) {
        m_fpsVisible = fpsVisible;
        emit fpsVisibleChanged();
    }
}

QString ClusterManagerBase::skin() const
{
    return m_skin;
}

void ClusterManagerBase::setSkin(const QString& skin)
{
    if (m_skin != skin) {
        m_skin = skin;
        emit skinChanged();
    }
}

QStringList ClusterManagerBase::skinList() const
{
    return m_skinList;
}

QString ClusterManagerBase::impPath() const
{
    return m_impPath;
}

QString ClusterManagerBase::impSkinPath() const
{
    return m_impSkinPath;
}

QString ClusterManagerBase::currentPath() const
{
    return QDir::currentPath();
}

QString ClusterManagerBase::configPath() const
{
    return QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);
}

QString ClusterManagerBase::docPath() const
{
    return QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
}

QString ClusterManagerBase::tmpPath() const
{
    return QStandardPaths::writableLocation(QStandardPaths::TempLocation);
}

QString ClusterManagerBase::platformDocPath() const
{
#ifdef CLUSTER_PLATFORM_DOC_PATH
    if (QDir().exists(QStringLiteral(CLUSTER_PLATFORM_DOC_PATH))) {
        return QStringLiteral(CLUSTER_PLATFORM_DOC_PATH);
    } else {
        return docPath();
    }
#else
    return docPath();
#endif
}

void ClusterManagerBase::receiveClientCommand(const QString& command)
{
    emit commandChanged(command);
}

void ClusterManagerBase::initView()
{
    m_view = new QQuickView(0);
    QQmlEngine* qmlEngine = m_view->engine();
#if QT_VERSION_MAJOR < 6
    m_view->setClearBeforeRendering(true);
#endif
    m_view->setColor(QColor(Qt::transparent));
    m_view->setFlags(m_view->flags() | Qt::FramelessWindowHint);
    m_view->setPosition(0, 0);
    connect(qmlEngine, &QQmlEngine::quit, m_view, &QQuickView::close);
    connect(m_view, &QQuickView::frameSwapped, this, &ClusterManagerBase::configFps, Qt::QueuedConnection);
    connect(m_view, &QQuickView::sceneGraphInitialized, this, [this]() {
        ClusterLog::printToBoot(QStringLiteral("Showed"));
#ifdef CLUSTER_HAS_BOOT_DAEMON
        boot_unlock(m_appName.toUtf8());
#endif
    });
    installReplicas();
}

void ClusterManagerBase::initSkin()
{
    QString prefix = m_impPath;
    if (!prefix.isEmpty()) {
        prefix.append(QStringLiteral("/"));
    }
    m_impSkinPath = QStringLiteral("none");
    connect(this, &ClusterManagerBase::skinChanged, this, [=]() {
        QString skinPath = m_impSkinPath;
        if (m_skinList.contains(m_skin)) {
            skinPath = prefix + QStringLiteral("qrc:/") + m_skin;
        } else {
            skinPath = prefix + QStringLiteral("qrc:/") + QStringLiteral("none");
        }
        if (m_impSkinPath != skinPath) {
            m_impSkinPath = skinPath;
            emit impSkinPathChanged();
        }
    });
    if (!m_skinList.isEmpty()) {
        if (m_skin.isEmpty() || m_skin == QStringLiteral("none")) {
            setSkin(m_skinList.first());
        }
    }
}

void ClusterManagerBase::initReplica(QRemoteObjectNode* node, QRemoteObjectReplica* replica, const QString& nodeName, const QUrl& url)
{
    QUrl connectUrl = url;
    if (connectUrl.isEmpty()) {
        connectUrl = QUrl(QStringLiteral("local:") + nodeName);
    }
    node->connectToNode(connectUrl);
    QQmlEngine::setObjectOwnership(replica, QQmlEngine::CppOwnership);
}

void ClusterManagerBase::configFps()
{
    if (m_fpsVisible == false) {
        return;
    }
    m_frameSwappedCount++;
    if (m_frameSwappedTime.elapsed() > 1000) {
        m_frameSwappedTime.restart();
        if (m_fps != m_frameSwappedCount) {
            m_fps = m_frameSwappedCount;
            emit fpsChanged();
        }
        m_frameSwappedCount = 0;
    }
}
