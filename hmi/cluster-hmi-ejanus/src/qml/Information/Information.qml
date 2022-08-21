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
    id: information
    property alias gear: gearAndTrip.gear
    property alias total: gearAndTrip.total
    property alias trip: gearAndTrip.trip
    property alias date: timeRect.date
    property alias temp: temperatureRect.temp
    property alias speed: adas.speed
    function show() {
        timeRect.show()
        temperatureRect.show()
        adas.show()
        gearAndTrip.show()
    }
    function hide() {
        timeRect.hide()
        temperatureRect.hide()
        adas.hide()
        gearAndTrip.hide()
    }
    TemperatureRect {
        id: temperatureRect
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 25
        anchors.topMargin: 20
    }
    TimeRect {
        id: timeRect
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 25
        anchors.topMargin: 20
    }
    Adas {
        id: adas
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
    }
    GearAndTrip {
        id: gearAndTrip
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
    }
}
