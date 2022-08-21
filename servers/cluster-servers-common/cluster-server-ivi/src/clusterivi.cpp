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

#include "clusterivi.h"
#ifdef CLUSTER_HAS_FDBUS
#include "clusterivi_fdbus.hpp"
#endif
#ifdef CLUSTER_HAS_VSOMEIP
#include "clusterivi_vsomeip.hpp"
#endif
#include <QBuffer>
#include <QProcess>
#include <QThread>
#include <QTimerEvent>
#include <cluster/clusterlog.h>

#define CLUSTER_IVI_HAS_MEDIA_PAGE 0

#define CLUSTER_IMG_HEADER "data:image/png;base64,"

extern bool __ENABLE_TEST;

static int timerID1 = -1;
static int timerID2 = -1;
static uint testID1 = 0;
static uint testID2 = 0;

ClusterIvi::ClusterIvi(QObject* parent)
    : ClusterIviSimpleSource(parent)
{
#if !CLUSTER_IVI_HAS_MEDIA_PAGE
    connect(this, &ClusterIvi::phoneChanged, this, &ClusterIvi::dealMediaPage);
    connect(this, &ClusterIvi::musicChanged, this, &ClusterIvi::dealMediaPage);
    connect(this, &ClusterIvi::radioChanged, this, &ClusterIvi::dealMediaPage);
#endif
#ifdef CLUSTER_HAS_FDBUS
    FDB_CONTEXT->start();
    FDBClusterClient::Create(this);
    FDBClusterServer::Create(this);
#endif
#ifdef CLUSTER_HAS_VSOMEIP
    VSomeipApp::Create(this);
#endif
    if (__ENABLE_TEST) {
        timerID1 = this->startTimer(600, Qt::CoarseTimer);
        timerID2 = this->startTimer(15000, Qt::CoarseTimer);
        setConnected(true);
        setSkin(QStringLiteral("blue"));
        setMediaPage(NORMAL);
        setRadio(RADIO_DEFAULT);
        setPhone(PHONE_DEFAULT);
        setMusic(MUSIC_DEFAULT);
        setNavi(Navi(false));
    }
}

ClusterIvi::~ClusterIvi()
{
#ifdef CLUSTER_HAS_FDBUS
    FDBClusterClient::Destroy();
    FDBClusterServer::Destroy();
    FDB_CONTEXT->destroy();
#endif
#ifdef CLUSTER_HAS_VSOMEIP
    VSomeipApp::Destroy();
#endif
}

void ClusterIvi::dealMsg(const QString& msgName, const QVariant& msgData)
{
    if (msgName.isEmpty()) {
        return;
    }
    QString targetMsg = msgName.toLower();
    if (targetMsg == QStringLiteral("connect")) {
        setConnected(msgData.toBool());
    } else if (targetMsg == QStringLiteral("radio")) {
        setRadio(msgData.value<Radio>());
    } else if (targetMsg == QStringLiteral("music")) {
        setMusic(msgData.value<Music>());
    } else if (targetMsg == QStringLiteral("phone")) {
        setPhone(msgData.value<Phone>());
    } else if (targetMsg == QStringLiteral("mediapage")) {
#if CLUSTER_IVI_HAS_MEDIA_PAGE
        setMediaPage((MediaPage)msgData.toInt());
#endif
    } else if (targetMsg == QStringLiteral("mediareset")) {
        resetMedia();
    } else if (targetMsg == QStringLiteral("navi")) {
        setNavi(msgData.value<Navi>());
    } else if (targetMsg == QStringLiteral("skin")) {
        setSkin(msgData.toString());
    } else if (targetMsg == QStringLiteral("splash")) {
        Splash splash = msgData.value<Splash>();
        bool visible = splash.visible();
        if (visible == false) {
            QProcess::execute(QStringLiteral("qplayer_scheduler"), QStringList() << QStringLiteral("-s") << QString::number(splash.id()));
        }
    } else if (targetMsg == QStringLiteral("dms")) {
        setDms(msgData.value<Dms>());
    } else if (targetMsg == QStringLiteral("v2x")) {
        setV2x(msgData.value<V2x>());
    }
}

void ClusterIvi::dealMediaPage()
{
    if (phone().status() != HANGUP) {
        setMediaPage(PHONE);
    } else if (music().status() != STOPED) {
        setMediaPage(MUSIC);
    } else if (radio().status() != CLOSED) {
        setMediaPage(RADIO);
    } else {
        setMediaPage(NORMAL);
    }
}

void ClusterIvi::resetMedia()
{
    setMediaPage(NORMAL);
    setRadio(RADIO_DEFAULT);
    setPhone(PHONE_DEFAULT);
    setMusic(MUSIC_DEFAULT);
}

bool ClusterIvi::getVersion(QString& text, int& majorNum, int& minorNum, int& revisionNum, bool& beta, QString& commitId)
{
    text = QStringLiteral(CLUSTER_VERSION);
    commitId = QStringLiteral(CLUSTER_COMMITID);
    QString numString = text;
    QString partString;
    int pstr = text.indexOf("-");
    if (pstr >= 0) {
        numString = text.left(pstr).toLower();
        partString = text.mid(pstr, text.length() - pstr).toLower();
    }
    beta = partString.contains("beta");

    QStringList vl = numString.split(".");
    if (vl.count() != 3) {
        majorNum = 0;
        minorNum = 0;
        revisionNum = 0;
        return false;
    }
    bool ok1 = false;
    bool ok2 = false;
    bool ok3 = false;
    majorNum = vl.at(0).toInt(&ok1);
    minorNum = vl.at(1).toInt(&ok2);
    revisionNum = vl.at(2).toInt(&ok3);
    return ok1 && ok2 && ok3;
}

QString ClusterIvi::getSourceForImage(const QImage& image)
{
    if (image.isNull()) {
        return QString();
    }
    QByteArray byteArray;
    QBuffer buffer(&byteArray);
    buffer.open(QIODevice::WriteOnly);
    image.save(&buffer, "PNG");
    buffer.close();
    QString source(QStringLiteral(CLUSTER_IMG_HEADER));
    source.append(QString::fromUtf8(byteArray.toBase64()));
    return source;
}

void ClusterIvi::timerEvent(QTimerEvent* event)
{
    Q_UNUSED(event)
    if (__ENABLE_TEST == false) {
        return;
    }
    if (event->timerId() == timerID1) {
        if (testID1 % 100 == 5) {
            setRadio(Radio(1, QStringLiteral("96.8")));
#if CLUSTER_IVI_HAS_MEDIA_PAGE
            setMediaPage(RADIO);
#endif
            setNavi(Navi(false));
        } else if (testID1 % 100 == 10) {
            setRadio(Radio(FM, QStringLiteral("98.2")));
        } else if (testID1 % 100 == 15) {
            setRadio(Radio(FM, QStringLiteral("101.5")));
        } else if (testID1 % 100 == 20) {
            setNavi(Navi(true));
        } else if (testID1 % 100 == 30) {
            setNavi(Navi(false));
        } else if (testID1 % 100 == 35) {
            setRadio(Radio(AM, QStringLiteral("680.0")));
            setNavi(Navi(false));
        } else if (testID1 % 100 == 40) {
            setRadio(Radio(AM, QStringLiteral("800.0")));
        } else if (testID1 % 100 == 45) {
            setRadio(Radio(CLOSED, QStringLiteral("0")));
        } else if (testID1 % 100 == 50) {
            setPhone(Phone(INCOMMING, QStringLiteral("Tom"), QStringLiteral("12345678912"), 0, ImageData(getSourceForImage(QImage(QStringLiteral("./1.png"))), false)));
#if CLUSTER_IVI_HAS_MEDIA_PAGE
            setMediaPage(PHONE);
#endif
        } else if (testID1 % 100 == 51) {
            setPhone(Phone(INCOMMING, QStringLiteral("Tom"), QStringLiteral("12345678912"), 0, ImageData("", true)));
        } else if (testID1 % 100 == 52) {
            setPhone(Phone(INCOMMING, QStringLiteral("Tom"), QStringLiteral("12345678912"), 0, ImageData("", true)));
        } else if (testID1 % 100 == 53) {
            setPhone(Phone(INCOMMING, QStringLiteral("Tom"), QStringLiteral("12345678912"), 0, ImageData("", true)));
        } else if (testID1 % 100 == 54) {
            setPhone(Phone(OUTGOING, QStringLiteral("Amy"), QStringLiteral("14785236974"), 0, ImageData(getSourceForImage(QImage(QStringLiteral("./1.png"))), false)));
        } else if (testID1 % 100 == 55) {
            setPhone(Phone(OUTGOING, QStringLiteral("Amy"), QStringLiteral("14785236974"), 0, ImageData("", true)));
        } else if (testID1 % 100 == 56) {
            setPhone(Phone(OUTGOING, QStringLiteral("Amy"), QStringLiteral("14785236974"), 0, ImageData("", true)));
        } else if (testID1 % 100 == 57) {
            setPhone(Phone(TALKING, QStringLiteral("Amy"), QStringLiteral("14785236974"), 0, ImageData("", true)));
        } else if (testID1 % 100 == 58) {
            setPhone(Phone(TALKING, QStringLiteral("Amy"), QStringLiteral("14785236974"), 1, ImageData("", true)));
        } else if (testID1 % 100 == 59) {
            setPhone(Phone(TALKING, QStringLiteral("Amy"), QStringLiteral("14785236974"), 2, ImageData("", true)));
        } else if (testID1 % 100 == 60) {
            setPhone(Phone(TALKING, QStringLiteral("Amy"), QStringLiteral("14785236974"), 3, ImageData("", true)));
        } else if (testID1 % 100 == 61) {
            setPhone(Phone(TALKING, QStringLiteral("Amy"), QStringLiteral("14785236974"), 4, ImageData("", true)));
        } else if (testID1 % 100 == 62) {
            setPhone(Phone(HANGUP, QStringLiteral("Amy"), QStringLiteral("14785236974"), 5, ImageData("", true)));
        } else if (testID1 % 100 == 63) {
            setMusic(Music(PLAYING, QStringLiteral("童话"), QStringLiteral("光良"), QStringLiteral("童话"), 0, 70, ImageData(getSourceForImage(QImage(QStringLiteral("./2.png"))), false)));
#if CLUSTER_IVI_HAS_MEDIA_PAGE
            setMediaPage(MUSIC);
#endif
        } else if (testID1 % 100 == 64) {
            setMusic(Music(PLAYING, QStringLiteral("童话"), QStringLiteral("光良"), QStringLiteral("童话"), 1, 70, ImageData("", true)));
        } else if (testID1 % 100 == 65) {
            setMusic(Music(PLAYING, QStringLiteral("童话"), QStringLiteral("光良"), QStringLiteral("童话"), 2, 70, ImageData("", true)));
        } else if (testID1 % 100 == 66) {
            setMusic(Music(PLAYING, QStringLiteral("童话"), QStringLiteral("光良"), QStringLiteral("童话"), 3, 70, ImageData("", true)));
        } else if (testID1 % 100 == 67) {
            setMusic(Music(PLAYING, QStringLiteral("童话"), QStringLiteral("光良"), QStringLiteral("童话"), 4, 70, ImageData("", true)));
        } else if (testID1 % 100 == 68) {
            setMusic(Music(PLAYING, QStringLiteral("童话"), QStringLiteral("光良"), QStringLiteral("童话"), 5, 70, ImageData("", true)));
        } else if (testID1 % 100 == 69) {
            setMusic(Music(PLAYING, QStringLiteral("童话"), QStringLiteral("光良"), QStringLiteral("童话"), 6, 70, ImageData("", true)));
        } else if (testID1 % 100 == 70) {
            setMusic(Music(PAUSING, QStringLiteral("双节棍"), QStringLiteral("周杰伦"), QStringLiteral("范特西"), 0, 89, ImageData(getSourceForImage(QImage(QStringLiteral("./1.png"))), false)));
        } else if (testID1 % 100 == 71) {
            setMusic(Music(PLAYING, QStringLiteral("双节棍"), QStringLiteral("周杰伦"), QStringLiteral("范特西"), 1, 89, ImageData("", true)));
        } else if (testID1 % 100 == 72) {
            setMusic(Music(PLAYING, QStringLiteral("双节棍"), QStringLiteral("周杰伦"), QStringLiteral("范特西"), 2, 89, ImageData("", true)));
        } else if (testID1 % 100 == 73) {
            setMusic(Music(PLAYING, QStringLiteral("双节棍"), QStringLiteral("周杰伦"), QStringLiteral("范特西"), 3, 89, ImageData("", true)));
        } else if (testID1 % 100 == 74) {
            setMusic(Music(PLAYING, QStringLiteral("双节棍"), QStringLiteral("周杰伦"), QStringLiteral("范特西"), 4, 89, ImageData("", true)));
        } else if (testID1 % 100 == 75) {
            setMusic(Music(PLAYING, QStringLiteral("双节棍"), QStringLiteral("周杰伦"), QStringLiteral("范特西"), 5, 89, ImageData("", true)));
        } else if (testID1 % 100 == 76) {
            setMusic(Music(PAUSING, QStringLiteral("双节棍"), QStringLiteral("周杰伦"), QStringLiteral("范特西"), 6, 89, ImageData("", true)));
            setNavi(Navi(true));
        } else if (testID1 % 100 == 80) {
            setDms(Dms(ATTENTION, 1));
        } else if (testID1 % 100 == 85) {
            setDms(Dms(TIRED, 2));
        } else if (testID1 % 100 == 90) {
            setDms(Dms(INVALID, 0));
            setNavi(Navi(true));
        }
        testID1++;
        if (testID1 >= 10000) {
            testID1 = 0;
        }
    } else if (event->timerId() == timerID2) {
        if (testID2 % 10 == 0) {
            setSkin(QStringLiteral("green"));
        } else if (testID2 % 10 == 1) {
            setSkin(QStringLiteral("dark"));
        } else if (testID2 % 10 == 2) {
            setSkin(QStringLiteral("golden"));
        } else if (testID2 % 10 == 3) {
            setSkin(QStringLiteral("pink"));
        } else if (testID2 % 10 == 4) {
            setSkin(QStringLiteral("light"));
        } else if (testID2 % 10 == 5) {
            setSkin(QStringLiteral("blue"));
        }
        testID2++;
        if (testID2 >= 10000) {
            testID2 = 0;
        }
    }
}

void ClusterIvi::receiveClientCommand(const QString& command)
{
    qDebug() << command;
    QStringList paras = command.split("=");
    if (paras.length() != 2) {
        return;
    }
    QString key = paras.at(0).toLower().trimmed();
    QString value = paras.at(1).toLower().trimmed();
    if (key == QStringLiteral("connected")) {
        setConnected(value.toInt());
    } else if (key == QStringLiteral("test")) {
        __ENABLE_TEST = (bool)value.toInt();
    } else if (key == QStringLiteral("skin")) {
        setSkin(value);
    } else if (key == QStringLiteral("mediapage")) {
        setMediaPage((MediaPage)value.toInt());
    } else if (key == QStringLiteral("mediareset")) {
        resetMedia();
    } else if (key == QStringLiteral("navi")) {
        setNavi(Navi(value.toInt()));
    }
    ClusterServerProxy<ClusterIvi>::receiveClientCommand(command);
}
