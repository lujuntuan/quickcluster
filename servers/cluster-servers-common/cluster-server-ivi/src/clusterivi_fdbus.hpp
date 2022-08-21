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

#ifndef CLUSTER_IVI_FDBUS_H
#define CLUSTER_IVI_FDBUS_H

#define FDBUS_IVI_URL "svc://ivi_fdbus"
#define FDBUS_CLUSTER_URL "svc://cluster_fdbus"

#include "cluster.pb.h"
#include "clusterivi.h"
#include "ivi.pb.h"
#include <QDebug>
#include <common_base/CFdbProtoMsgBuilder.h>
#include <common_base/fdbus.h>

#define STRING(x) #x
#define PARSER_MSG(msg, msgData, ok)                             \
    if (msgData->getPayloadSize() == 0) {                        \
        ok = true;                                               \
    } else {                                                     \
        CFdbProtoMsgParser parser(msg);                          \
        ok = msgData->deserialize(parser);                       \
        if (!ok) {                                               \
            qWarning() << STRING(fdbus deserialize msg error !); \
        }                                                        \
    }

static void deal_connect(ClusterIvi* ivi);

class FDBClusterClient : public CBaseClient {
public:
    static void Create(ClusterIvi* ivi)
    {
        if (_instance) {
            qWarning() << QStringLiteral("FDBClusterClient must be singleton mode!");
            return;
        }
        _instance = new FDBClusterClient(ivi);
    }
    static void Destroy()
    {
        if (_instance) {
            delete _instance;
            _instance = nullptr;
        }
    }
    static FDBClusterClient* GetInstance()
    {
        return _instance;
    }

private:
    FDBClusterClient(ClusterIvi* ivi)
        : CBaseClient("cluster_client")
        , m_ivi(ivi)
    {
        this->enableReconnect(true);
        this->connect(FDBUS_IVI_URL);
    }
    ~FDBClusterClient()
    {
    }
    void onOnline(FdbSessionId_t sid, bool is_first) override
    {
        (void)sid;
        (void)is_first;
        deal_connect(m_ivi);

        CFdbMsgSubscribeList subscribe_list;
        addNotifyItem(subscribe_list, IVI::TYPE_RADIO);
        addNotifyItem(subscribe_list, IVI::TYPE_MUSIC);
        addNotifyItem(subscribe_list, IVI::TYPE_PHONE);
        addNotifyItem(subscribe_list, IVI::TYPE_MEDIA_PAGE);
        addNotifyItem(subscribe_list, IVI::TYPE_NAVI);
        addNotifyItem(subscribe_list, IVI::TYPE_SKIN);
        addNotifyItem(subscribe_list, IVI::TYPE_SPLASH);
        addNotifyItem(subscribe_list, IVI::TYPE_DMS);
        addNotifyItem(subscribe_list, IVI::TYPE_V2X);
        subscribe(subscribe_list);
    }
    void onOffline(FdbSessionId_t sid, bool is_last) override
    {
        (void)sid;
        (void)is_last;
        deal_connect(m_ivi);
    }
    void onBroadcast(CBaseJob::Ptr& msg_ref) override
    {
        CFdbMessage* msgData = castToMessage<CBaseMessage*>(msg_ref);
        CFdbSession* session = FDB_CONTEXT->getSession(msgData->session());
        if (!session) {
            return;
        }
        bool ok = false;
        if (msgData->code() == IVI::TYPE_RADIO) {
            IVI::Radio msgRadio;
            PARSER_MSG(msgRadio, msgData, ok);
            if (ok) {
                Radio radio((IVI::Radio::Status)msgRadio.status(),
                    msgRadio.frequency().data());
                QMetaObject::invokeMethod(m_ivi, "dealMsg", Qt::QueuedConnection, Q_ARG(QString, QStringLiteral("radio")), Q_ARG(QVariant, QVariant::fromValue<Radio>(radio)));
            }
        } else if (msgData->code() == IVI::TYPE_MUSIC) {
            IVI::Music msgMusic;
            PARSER_MSG(msgMusic, msgData, ok);
            if (ok) {
                Music music((IVI::Music::Status)msgMusic.status(),
                    msgMusic.name().data(),
                    msgMusic.author().data(),
                    msgMusic.album().data(),
                    msgMusic.time(),
                    msgMusic.total(),
                    ImageData(msgMusic.image().source().data(), msgMusic.image().cache()));
                QMetaObject::invokeMethod(m_ivi, "dealMsg", Qt::QueuedConnection, Q_ARG(QString, QStringLiteral("music")), Q_ARG(QVariant, QVariant::fromValue<Music>(music)));
            }
        } else if (msgData->code() == IVI::TYPE_PHONE) {
            IVI::Phone msgPhone;
            PARSER_MSG(msgPhone, msgData, ok);
            if (ok) {
                Phone phone((IVI::Phone::Status)msgPhone.status(),
                    msgPhone.name().data(),
                    msgPhone.nummber().data(),
                    msgPhone.time(),
                    ImageData(msgPhone.image().source().data(), msgPhone.image().cache()));
                QMetaObject::invokeMethod(m_ivi, "dealMsg", Qt::QueuedConnection, Q_ARG(QString, QStringLiteral("phone")), Q_ARG(QVariant, QVariant::fromValue<Phone>(phone)));
            }
        } else if (msgData->code() == IVI::TYPE_MEDIA_PAGE) {
            IVI::MediaPage msgMediaPage;
            PARSER_MSG(msgMediaPage, msgData, ok);
            if (ok) {
                QMetaObject::invokeMethod(m_ivi, "dealMsg", Qt::QueuedConnection, Q_ARG(QString, QStringLiteral("mediapage")), Q_ARG(QVariant, QVariant(msgMediaPage.status())));
            }
        } else if (msgData->code() == IVI::TYPE_MEDIA_RESET) {
            QMetaObject::invokeMethod(m_ivi, "dealMsg", Qt::QueuedConnection, Q_ARG(QString, QStringLiteral("mediareset")), Q_ARG(QVariant, QVariant(QString("mediareset"))));
        } else if (msgData->code() == IVI::TYPE_NAVI) {
            IVI::Navi msgNavi;
            PARSER_MSG(msgNavi, msgData, ok);
            if (ok) {
                Navi navi(msgNavi.visible());
                QMetaObject::invokeMethod(m_ivi, "dealMsg", Qt::QueuedConnection, Q_ARG(QString, QStringLiteral("navi")), Q_ARG(QVariant, QVariant::fromValue<Navi>(navi)));
            }
        } else if (msgData->code() == IVI::TYPE_SKIN) {
            IVI::Skin msgSkin;
            PARSER_MSG(msgSkin, msgData, ok);
            if (ok) {
                QMetaObject::invokeMethod(m_ivi, "dealMsg", Qt::QueuedConnection, Q_ARG(QString, QStringLiteral("skin")), Q_ARG(QVariant, QVariant(QString(msgSkin.name().data()))));
            }
        } else if (msgData->code() == IVI::TYPE_SPLASH) {
            IVI::Splash msgSplash;
            PARSER_MSG(msgSplash, msgData, ok);
            if (ok) {
                Splash splash(msgSplash.id(), msgSplash.visible());
                QMetaObject::invokeMethod(m_ivi, "dealMsg", Qt::QueuedConnection, Q_ARG(QString, QStringLiteral("splash")), Q_ARG(QVariant, QVariant::fromValue<Splash>(splash)));
            }
        } else if (msgData->code() == IVI::TYPE_DMS) {
            IVI::Dms msgDms;
            PARSER_MSG(msgDms, msgData, ok);
            if (ok) {
                Dms dms(msgDms.status(), msgDms.level());
                QMetaObject::invokeMethod(m_ivi, "dealMsg", Qt::QueuedConnection, Q_ARG(QString, QStringLiteral("dms")), Q_ARG(QVariant, QVariant::fromValue<Dms>(dms)));
            }
        } else if (msgData->code() == IVI::TYPE_V2X) {
            IVI::V2x msgV2x;
            PARSER_MSG(msgV2x, msgData, ok);
            if (ok) {
                V2x v2x(QByteArray(msgV2x.data().data()));
                QMetaObject::invokeMethod(m_ivi, "dealMsg", Qt::QueuedConnection, Q_ARG(QString, QStringLiteral("v2x")), Q_ARG(QVariant, QVariant::fromValue<V2x>(v2x)));
            }
        } else {
            qWarning() << QStringLiteral("Can not receive this FdbMsgCode_t(%1) in 'onBroadcast' function.").arg(QString::number(msgData->code()));
        }
    }

private:
    static FDBClusterClient* _instance;
    ClusterIvi* m_ivi = nullptr;
};

class FDBClusterServer : public CBaseServer {
public:
    static void Create(ClusterIvi* ivi)
    {
        if (_instance) {
            return;
        }
        _instance = new FDBClusterServer(ivi);
    }
    static void Destroy()
    {
        if (_instance) {
            delete _instance;
            _instance = nullptr;
        }
    }
    static FDBClusterServer* GetInstance()
    {
        return _instance;
    }

private:
    FDBClusterServer(ClusterIvi* ivi)
        : CBaseServer("cluster_server")
        , m_ivi(ivi)
    {
        this->enableReconnect(true);
        this->bind(FDBUS_CLUSTER_URL);
    }
    ~FDBClusterServer()
    {
    }
    void onOnline(FdbSessionId_t sid, bool is_first) override
    {
        (void)sid;
        (void)is_first;
        deal_connect(m_ivi);
    }
    void onOffline(FdbSessionId_t sid, bool is_last) override
    {
        (void)sid;
        (void)is_last;
        deal_connect(m_ivi);
    }
    void onInvoke(CBaseJob::Ptr& msg_ref) override
    {
        CFdbMessage* msgData = castToMessage<CBaseMessage*>(msg_ref);
        CFdbSession* session = FDB_CONTEXT->getSession(msgData->session());
        if (!session) {
            return;
        }
        if (msgData->code() == CLUSTER::TYPE_VERSION) {
            CLUSTER::Version msgVersion;
            QString text;
            int majorNum = 0;
            int minorNum = 0;
            int revisionNum = 0;
            bool beta = false;
            QString commitid;
            m_ivi->getVersion(text, majorNum, minorNum, revisionNum, beta, commitid);
            msgVersion.set_text(text.toUtf8());
            msgVersion.set_major_num(majorNum);
            msgVersion.set_minor_num(minorNum);
            msgVersion.set_revision_num(revisionNum);
            msgVersion.set_beta(beta);
            msgVersion.set_commit_id(commitid.toUtf8());
            CFdbProtoMsgBuilder versionBuilder(msgVersion);
            msgData->reply(msg_ref, versionBuilder);
        } else {
            qWarning() << QStringLiteral("Can not receive this FdbMsgCode_t(%1) in 'onInvoke' function.").arg(QString::number(msgData->code()));
        }
    }

private:
    static FDBClusterServer* _instance;
    ClusterIvi* m_ivi = nullptr;
};

static void deal_connect(ClusterIvi* ivi)
{
    bool isConnected = FDBClusterServer::GetInstance()->getSessionCount() > 0 && FDBClusterClient::GetInstance()->getSessionCount() > 0;
    QMetaObject::invokeMethod(ivi, "dealMsg", Qt::QueuedConnection, Q_ARG(QString, QStringLiteral("connect")), Q_ARG(QVariant, QVariant(isConnected)));
}

FDBClusterClient* FDBClusterClient::_instance = nullptr;
FDBClusterServer* FDBClusterServer::_instance = nullptr;

#endif // CLUSTER_IVI_FDBUS_H
