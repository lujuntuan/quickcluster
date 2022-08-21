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

SlideItem{
    id:tirePanel
    width: parent.width
    height: parent.height
    property var tireFrontLeft: {"temp":0,"pressure":0}
    property var tireFrontRight: {"temp":0,"pressure":0}
    property var tireBehindLeft: {"temp":0,"pressure":0}
    property var tireBehindRight: {"temp":0,"pressure":0}
    Image {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -10
        source: ClusterManager.impSkinPath+"/tirePressure/car.png"
        antialiasing: true
        Tire{
            anchors.left: parent.left
            anchors.leftMargin: 1
            anchors.top: parent.top
            anchors.topMargin: 39
            temp: tireFrontLeft.temp
            pressure: tireFrontLeft.pressure
            type: 0
        }
        Tire{
            anchors.right: parent.right
            anchors.rightMargin: -1
            anchors.top: parent.top
            anchors.topMargin: 39
            temp: tireFrontRight.temp
            pressure: tireFrontRight.pressure
            type: 1
        }
        Tire{
            anchors.left: parent.left
            anchors.leftMargin: 1
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 25
            temp: tireBehindLeft.temp
            pressure: tireBehindLeft.pressure
            type: 0
        }
        Tire{
            anchors.right: parent.right
            anchors.rightMargin: -1
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 25
            temp: tireBehindRight.temp
            pressure: tireBehindRight.pressure
            type: 1
        }
    }

}
