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

import QtQuick 2.15
import Cluster 1.0
import "../Common"

Item {
    id: doubleGauge
    property real speed: 0 //0-240
    property real engine: 0 //0-7000
    property real fuel: 0 //0-102
    property real temp: 0 //0-130
    property real water: 999
    property real avgFuel: 0
    property real maxFuel: 0
    property int gear: 0
    property date date: new Date(1970, 1, 1, 0, 0, 0)
    property real total: -1
    property real trip: -1
    property bool leftSignal: false
    property bool rightSignal: false
    property alias backImg: backImg
    property alias partItem: partItem
    enabled: false
    enum Gear {
        GEAR_P = 0,
        GEAR_R = 1,
        GEAR_N = 2,
        GEAR_D = 3
    }
    visible: opacity > 0
    opacity: 0
    //-------------background
    Image {
        id: backImg
        anchors.centerIn: parent
        source: ClusterManager.impSkinPath + "/doubleGuage/bg.png"
    }
    //-------------speed
    Image {
        id: speedDial
        readonly property int hundred_speed: doubleGauge.visible ? doubleGauge.speed / 100 : 0
        readonly property int decade_speed: doubleGauge.visible ? doubleGauge.speed / 10 % 10 : 0
        readonly property int number_speed: doubleGauge.visible ? doubleGauge.speed % 10 : 0
        readonly property int thousand_engine: doubleGauge.visible ? (doubleGauge.engine
                                                                      / 1000).toFixed(
                                                                         0) : 0
        source: ClusterManager.impSkinPath + "/doubleGuage/Speedometer_bg.png"
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        Image {
            id: pointer_speed
            x: parent.width / 2 - width / 2 + 50
            y: parent.width / 2 - width / 2 - 50
            width: 403
            height: 403
            source: ClusterManager.impSkinPath + "/doubleGuage/pointer.png"
            transform: [
                Rotation {
                    axis.x: 1
                    axis.y: 1.2
                    axis.z: 0
                    origin.x: pointer_speed.width / 2
                    origin.y: pointer_speed.height / 2
                    angle: 60
                }
            ]
            rotation: doubleGauge.visible ? doubleGauge.speed / 240.0 * 130.0 + 160 : 160
        }
        Row {
            anchors.top: parent.top
            anchors.topMargin: 30
            x: parent.width / 2 - width / 2 + 70
            spacing: 0
            width: {
                if (doubleGauge.visible === true) {
                    if (doubleGauge.speed >= 100) {
                        return digitalnum1.width * 3 + spacing * 2
                    } else if (doubleGauge.speed >= 10) {
                        return digitalnum1.width * 2 + spacing
                    } else {
                        return digitalnum1.width
                    }
                } else {
                    return digitalnum1.width
                }
            }
            ImageClip {
                id: digitalnum1
                width: 100
                height: 100
                index: doubleGauge.visible ? speedDial.hundred_speed : 0
                visible: (doubleGauge.visible) && doubleGauge.speed >= 100
                source: ClusterManager.impSkinPath + "/doubleGuage/doubledigital_100_100.png"
            }
            ImageClip {
                width: 100
                height: 100
                index: doubleGauge.visible ? speedDial.decade_speed : 0
                visible: (doubleGauge.visible) && doubleGauge.speed >= 10
                source: ClusterManager.impSkinPath + "/doubleGuage/doubledigital_100_100.png"
            }
            ImageClip {
                width: 100
                height: 100
                index: doubleGauge.visible ? speedDial.number_speed : 0
                //visible: doubleGauge.visible===true
                source: ClusterManager.impSkinPath + "/doubleGuage/doubledigital_100_100.png"
            }
        }
        Image {
            source: ClusterManager.impSkinPath + "/doubleGuage/km_hour.png"
            anchors.top: parent.top
            anchors.topMargin: 130
            x: parent.width / 2 - width / 2 + 70
        }
    }
    //-------------engine
    Image {
        id: engineDial
        source: ClusterManager.impSkinPath + "/doubleGuage/tachometer_bg.png"
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        Image {
            id: pointer_engine
            x: parent.width / 2 - width / 2 - 50
            y: parent.width / 2 - width / 2 - 50
            width: 403
            height: 403
            source: ClusterManager.impSkinPath + "/doubleGuage/pointer.png"
            transform: [
                Rotation {
                    axis.x: 1
                    axis.y: -1.2
                    axis.z: 0
                    origin.x: pointer_engine.width / 2
                    origin.y: pointer_engine.height / 2
                    angle: 60
                }
            ]
            rotation: doubleGauge.visible ? -doubleGauge.engine / 7200.0 * 130.0 - 160 : -160
        }
        ImageClip {
            anchors.top: parent.top
            anchors.topMargin: 30
            x: parent.width / 2 - width / 2 - 70
            width: 100
            height: 100
            index: doubleGauge.visible ? speedDial.thousand_engine : 0
            //visible: doubleGauge.visible===true
            source: ClusterManager.impSkinPath + "/doubleGuage/doubledigital_100_100.png"
        }
        Image {
            source: ClusterManager.impSkinPath + "/doubleGuage/1000r_min.png"
            anchors.top: parent.top
            anchors.topMargin: 130
            x: parent.width / 2 - width / 2 - 70
        }
    }
    Item {
        id: partItem
        anchors.fill: parent
        opacity: 0
        scale: 0.85
        visible: opacity > 0
        DoublePart {
            id: doublePart
            anchors.fill: parent
        }
    }
}
