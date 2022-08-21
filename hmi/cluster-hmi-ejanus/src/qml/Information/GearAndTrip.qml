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
    id: gearAndTrip
    width: rect.width
    height: rect.height
    enum Gear {
        GEAR_P = 0,
        GEAR_R = 1,
        GEAR_N = 2,
        GEAR_D = 3
    }
    property int gear: 0
    property real total: -1
    property real trip: -1
    ParallelAnimation {
        id: ani
        NumberAnimation {
            id: ani1
            target: rect
            property: "opacity"
            duration: 500
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            id: ani2
            target: rect
            property: "y"
            duration: 500
            easing.type: Easing.OutCubic
        }
    }
    function show() {
        ani1.from = 0
        ani1.to = 1
        ani2.from = rect.height
        ani2.to = 0
        ani.restart()
    }
    function hide() {
        ani1.from = 1
        ani1.to = 0
        ani2.from = 0
        ani2.to = rect.height
        ani.restart()
    }
    Rectangle {
        id: rect
        color: "black"
        width: 800
        height: 70
        opacity: 0
        y: rect.height
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: Qt.rgba(0, 0, 0, 0)
            }
            GradientStop {
                position: 0.1
                color: Qt.rgba(0, 0, 0, 1)
            }
            GradientStop {
                position: 0.9
                color: Qt.rgba(0, 0, 0, 1)
            }
            GradientStop {
                position: 1.0
                color: Qt.rgba(0, 0, 0, 0)
            }
        }
        Row {
            height: 35
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 5
            spacing: 5
            Image {
                source: ClusterManager.impSkinPath + "/common/total_txt.png"
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0
            }
            CustomText {
                height: parent.height
                font.pixelSize: 30
                rightPadding: 10
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignRight
                text: gearAndTrip.total < 0 ? "---" : String(
                                                  gearAndTrip.total.toFixed(0))
                leftPadding: 5
            }
            Image {
                source: ClusterManager.impSkinPath + "/doubleGuage/km.png"
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 3
            }
            Item {
                width: 240
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                Row {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: 5
                    spacing: 8
                    Repeater {
                        model: 4
                        Image {
                            id: gearImg
                            property string name: {
                                switch (index) {
                                case GearAndTrip.GEAR_P:
                                    return "p"
                                case GearAndTrip.GEAR_R:
                                    return "r"
                                case GearAndTrip.GEAR_N:
                                    return "n"
                                case GearAndTrip.GEAR_D:
                                    return "d"
                                }
                            }
                            property bool isCurrent: gearAndTrip.gear === index
                            property string pname: isCurrent ? "current" : "normal"
                            source: ClusterManager.impSkinPath + "/gear/gear_"
                                    + name + "_" + pname + ".png"
                            onIsCurrentChanged: {
                                if (isCurrent === true) {
                                    gearAni.restart()
                                } else {
                                    gearAni.stop()
                                    gearImg.scale = 1
                                }
                            }
                            NumberAnimation {
                                id: gearAni
                                target: gearImg
                                property: "scale"
                                easing.type: Easing.OutCubic
                                duration: 200
                                from: 1.0
                                to: 1.25
                            }
                        }
                    }
                }
            }
            Image {
                source: ClusterManager.impSkinPath + "/common/trip_txt.png"
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 5
            }
            CustomText {
                height: parent.height
                font.pixelSize: 30
                rightPadding: 10
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignRight
                text: gearAndTrip.trip < 0 ? "---" : String(
                                                 gearAndTrip.trip.toFixed(1))
                leftPadding: 5
            }
            Image {
                source: ClusterManager.impSkinPath + "/doubleGuage/km.png"
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 3
            }
        }
    }
}
