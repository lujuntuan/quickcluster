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

Item {
    id: information
    property alias date: timeRect.date
    property alias temp: temperatureRect.temp
    property alias speed: adasRect.speed
    property alias gear: gearRect.gear
    property alias total: tripRect.total
    property alias trip: tripRect.trip
    property alias avgFuel: avgRect.avgFuel
    property alias avgSpeed: avgRect.avgSpeed
    property alias temperatureRect: temperatureRect
    property alias timeRect: timeRect
    property alias gearRect: gearRect
    property alias tripRect: tripRect
    property alias adasRect: adasRect
    property alias avgRect: avgRect
    function show() {
        timeRect.show()
        temperatureRect.show()
        adasRect.show()
        gearRect.show()
        tripRect.show()
        avgRect.show()
    }
    function hide() {
        timeRect.hide()
        temperatureRect.hide()
        adasRect.hide()
        gearRect.hide()
        tripRect.hide()
        avgRect.hide()
    }
    TemperatureRect {
        id: temperatureRect
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -350
        anchors.top: parent.top
        anchors.topMargin: 20
    }
    TimeRect {
        id: timeRect
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 350
        anchors.top: parent.top
        anchors.topMargin: 20
    }
    GearRect {
        id: gearRect
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 0
        anchors.top: parent.top
        anchors.topMargin: 20
    }
    TripRect {
        id: tripRect
        parent: dashboardPartItem
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
    }
    Adas {
        id: adasRect
        parent: dashboardPartItem
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -35
    }
    Avg{
        id: avgRect
        parent: dashboardPartItem
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 50
    }
}
