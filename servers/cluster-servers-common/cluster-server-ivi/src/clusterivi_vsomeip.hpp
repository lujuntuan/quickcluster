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

#ifndef CLUSTER_IVI_VSOMEIP_H
#define CLUSTER_IVI_VSOMEIP_H

#include "cluster.pb.h"
#include "clusterivi.h"
#include "vsomeip/vsomeip.hpp"
#include <QDebug>
#include <QFile>
#include <QProcess>
#include <QThread>
#include <google/protobuf/message.h>

#define IVI_SERVICE_ID 0x1102
#define IVI_INSTANCE_ID 0x1111

#define IVI_VERSION_MAJOR 1
#define IVI_VERSION_MINOR 0

#define IVI_OFFSET_VALUE 0x03ff

#define VSOMEIP_CFG_ENV "VSOMEIP_CONFIGURATION"

#define USE_SD_NAVI 0

static void deal_connect(ClusterIvi* ivi);

class VSomeipApp {
public:
    static void Create(ClusterIvi* ivi)
    {
        if (_instance) {
            qWarning() << QStringLiteral("VSomeipApp must be singleton mode!");
            return;
        }
        _instance = new VSomeipApp(ivi);
    }
    static void Destroy()
    {
        if (_instance) {
            delete _instance;
            _instance = nullptr;
        }
    }
    static VSomeipApp* GetInstance()
    {
        return _instance;
    }

private:
    VSomeipApp(ClusterIvi* ivi)
        : m_ivi(ivi)
        , m_vsomeipApp(vsomeip::runtime::get()->create_application("cluster"))
    {
        if (qEnvironmentVariableIsEmpty(VSOMEIP_CFG_ENV)) {
            QString cfgPath = "./etc/vsomeip/vsomeip-ivi.json";
            if (QFile::exists(cfgPath)) {
                qputenv(VSOMEIP_CFG_ENV, cfgPath.toLocal8Bit());
            } else {
                cfgPath = "/etc/vsomeip/vsomeip-ivi.json";
                if (QFile::exists(cfgPath)) {
                    qputenv(VSOMEIP_CFG_ENV, cfgPath.toLocal8Bit());
                } else {
                    cfgPath = "../etc/vsomeip/vsomeip-ivi.json";
                    if (QFile::exists(cfgPath)) {
                        qputenv(VSOMEIP_CFG_ENV, cfgPath.toLocal8Bit());
                    } else {
                        qWarning() << "Can not find configure json!";
                    }
                }
            }
        } else {
            if (!QFile::exists(qgetenv(VSOMEIP_CFG_ENV))) {
                qWarning() << "Can not find configure json for env!";
            }
        }
        QThread* thread = QThread::create([this]() {
            m_vsomeipApp->init();
            m_vsomeipApp->register_message_handler(vsomeip::ANY_SERVICE, vsomeip::ANY_INSTANCE, vsomeip::ANY_METHOD, std::bind(&VSomeipApp::onMessage, this, std::placeholders::_1));
            m_vsomeipApp->offer_service(IVI_SERVICE_ID, IVI_INSTANCE_ID, IVI_VERSION_MAJOR, IVI_VERSION_MINOR);
            m_vsomeipApp->start();
        });
        thread->start();
    }
    ~VSomeipApp()
    {
        m_vsomeipApp->stop();
    }
    void onMessage(const std::shared_ptr<vsomeip::message>& _request)
    {
        deal_connect(m_ivi);
        std::shared_ptr<vsomeip::payload> its_payload = _request->get_payload();
        int type = _request->get_method() & IVI_OFFSET_VALUE;
        switch (type) {
        case CLUSTER::TYPE_RADIO: {
            CLUSTER::Radio msgRadio;
            msgRadio.ParseFromArray(its_payload->get_data(), its_payload->get_length());
            Radio radio((CLUSTER::Radio::Status)msgRadio.status(), msgRadio.frequency().data());
            QMetaObject::invokeMethod(m_ivi, "dealMsg", Qt::QueuedConnection, Q_ARG(QString, QStringLiteral("radio")), Q_ARG(QVariant, QVariant::fromValue<Radio>(radio)));
            break;
        }
        case CLUSTER::TYPE_MUSIC: {
            CLUSTER::Music msgMusic;
            msgMusic.ParseFromArray(its_payload->get_data(), its_payload->get_length());
            Music music((CLUSTER::Music::Status)msgMusic.status(),
                msgMusic.name().data(),
                msgMusic.author().data(),
                msgMusic.album().data(),
                msgMusic.time(),
                msgMusic.total(),
                ImageData(msgMusic.image().source().data(), msgMusic.image().cache()));
            QMetaObject::invokeMethod(m_ivi, "dealMsg", Qt::QueuedConnection, Q_ARG(QString, QStringLiteral("music")), Q_ARG(QVariant, QVariant::fromValue<Music>(music)));
            break;
        }
        case CLUSTER::TYPE_PHONE: {
            CLUSTER::Phone msgPhone;
            msgPhone.ParseFromArray(its_payload->get_data(), its_payload->get_length());
            Phone phone((CLUSTER::Phone::Status)msgPhone.status(),
                msgPhone.name().data(),
                msgPhone.nummber().data(),
                msgPhone.time(),
                ImageData(msgPhone.image().source().data(), msgPhone.image().cache()));
            QMetaObject::invokeMethod(m_ivi, "dealMsg", Qt::QueuedConnection, Q_ARG(QString, QStringLiteral("phone")), Q_ARG(QVariant, QVariant::fromValue<Phone>(phone)));
            break;
        }
        case CLUSTER::TYPE_MEDIA_PAGE: {
            CLUSTER::MediaPage msgMediaPage;
            msgMediaPage.ParseFromArray(its_payload->get_data(), its_payload->get_length());
            QMetaObject::invokeMethod(m_ivi, "dealMsg", Qt::QueuedConnection, Q_ARG(QString, QStringLiteral("mediapage")), Q_ARG(QVariant, QVariant(msgMediaPage.status())));
            break;
        }
        case CLUSTER::TYPE_MEDIA_RESET: {
            QMetaObject::invokeMethod(m_ivi, "dealMsg", Qt::QueuedConnection, Q_ARG(QString, QStringLiteral("mediareset")), Q_ARG(QVariant, QVariant(QString("mediareset"))));
            break;
        }
        case CLUSTER::TYPE_NAVI: {
            CLUSTER::Navi msgNavi;
            msgNavi.ParseFromArray(its_payload->get_data(), its_payload->get_length());
            Navi navi(msgNavi.visible());
#if USE_SD_NAVI
            QProcess::execute(QStringLiteral("killall"), QStringList() << QStringLiteral("-9") << QStringLiteral("sdnavi"));
            if (msgNavi.visible()) {
                QProcess::startDetached(QStringLiteral("sdnavi"), QStringList());
            }
#endif
            QMetaObject::invokeMethod(m_ivi, "dealMsg", Qt::QueuedConnection, Q_ARG(QString, QStringLiteral("navi")), Q_ARG(QVariant, QVariant::fromValue<Navi>(navi)));
            break;
        }
        case CLUSTER::TYPE_SKIN: {
            CLUSTER::Skin msgSkin;
            msgSkin.ParseFromArray(its_payload->get_data(), its_payload->get_length());
            QMetaObject::invokeMethod(m_ivi, "dealMsg", Qt::QueuedConnection, Q_ARG(QString, QStringLiteral("skin")), Q_ARG(QVariant, QVariant(QString(msgSkin.name().data()))));
            break;
        }
        case CLUSTER::TYPE_SPLASH: {
            CLUSTER::Splash msgSplash;
            msgSplash.ParseFromArray(its_payload->get_data(), its_payload->get_length());
            Splash splash(msgSplash.id(), msgSplash.visible());
            QMetaObject::invokeMethod(m_ivi, "dealMsg", Qt::QueuedConnection, Q_ARG(QString, QStringLiteral("splash")), Q_ARG(QVariant, QVariant::fromValue<Splash>(splash)));
            break;
        }
        case CLUSTER::TYPE_DMS: {
            CLUSTER::Dms msgDms;
            msgDms.ParseFromArray(its_payload->get_data(), its_payload->get_length());
            Dms dms(msgDms.status(), msgDms.level());
            QMetaObject::invokeMethod(m_ivi, "dealMsg", Qt::QueuedConnection, Q_ARG(QString, QStringLiteral("dms")), Q_ARG(QVariant, QVariant::fromValue<Dms>(dms)));
            break;
        }
        case CLUSTER::TYPE_V2X: {
            CLUSTER::V2x msgV2x;
            msgV2x.ParseFromArray(its_payload->get_data(), its_payload->get_length());
            V2x v2x(QByteArray(msgV2x.data().data()));
            QMetaObject::invokeMethod(m_ivi, "dealMsg", Qt::QueuedConnection, Q_ARG(QString, QStringLiteral("v2x")), Q_ARG(QVariant, QVariant::fromValue<V2x>(v2x)));
            break;
        }
        case CLUSTER::TYPE_VERSION: {
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
            std::shared_ptr<vsomeip::message> its_response = vsomeip::runtime::get()->create_response(_request);
            its_payload = vsomeip::runtime::get()->create_payload();
            void* buffer = malloc(msgVersion.ByteSizeLong());
            msgVersion.SerializeToArray(buffer, msgVersion.ByteSizeLong());
            its_response->set_payload(its_payload);
            m_vsomeipApp->send(its_response);
            free(buffer);
            break;
        }
        default:
            break;
        }
    }

private:
    static VSomeipApp* _instance;
    ClusterIvi* m_ivi = nullptr;
    std::shared_ptr<vsomeip::application> m_vsomeipApp;
};

static void deal_connect(ClusterIvi* ivi)
{
    QMetaObject::invokeMethod(ivi, "dealMsg", Qt::QueuedConnection, Q_ARG(QString, QStringLiteral("connect")), Q_ARG(QVariant, QVariant(true)));
}

VSomeipApp* VSomeipApp::_instance = nullptr;

#endif // CLUSTER_IVI_VSOMEIP_H
