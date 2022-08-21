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

Item {
    id: dashboard
    anchors.fill: parent
    property real speed: 0
    property real engine: 0
    property real fuel: 0
    property real water: 0
    property real avgFuel: 0
    property real maxFuel: 0
    property bool emergency: false
    property bool inited: false
    property alias backImg: backImg
    property alias partItem: partItem
    visible: opacity>0
    opacity: 0
    enabled: false
    Image{
        id:backImg
        anchors.centerIn: parent
        source: ClusterManager.impSkinPath+"/navi/bg.png"
    }
    Binding {
        target: speedPanel
        when: dashboard.inited
        property: "value"
        value: dashboard.speed
    }
    Binding {
        target: enginePanel
        when: dashboard.inited
        property: "value"
        value: dashboard.engine
    }
    Binding {
        target: fuelPanel
        when: dashboard.inited
        property: "value"
        value: dashboard.fuel>dashboard.maxFuel?dashboard.maxFuel:dashboard.fuel
    }
    Binding {
        target: fuelPanel
        when: dashboard.inited
        property: "avgValue"
        value: dashboard.avgFuel
    }
    Binding {
        target: fuelPanel
        when: dashboard.inited
        property: "maxValue"
        value: dashboard.maxFuel
    }
    Binding {
        target: waterPanel
        when: dashboard.inited
        property: "value"
        value: dashboard.water
    }
    SpeedPanel{
        id: speedPanel
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
    }
    EnginePanel{
        id: enginePanel
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
    }
    FuelPanel {
        id: fuelPanel
        anchors.left: speedPanel.left
        anchors.leftMargin: 35
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 35
    }
    WaterPanel {
        id: waterPanel
        anchors.right: enginePanel.right
        anchors.rightMargin: 35
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 35
    }
    Item{
        id:partItem
        anchors.fill: parent
        opacity: 0
        scale: 0.85
        visible: opacity > 0
    }
}
