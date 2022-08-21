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
import "Animation"
import "Information"
import "Telltales"
import "MultiMedia"
import "MiniDashboard"
import "Dms"
import "CarInfo"
import "Common"
import "Navi"

Item {
    id: mainPart
    property bool ivsEnabled: ClusterIvs.connected && ClusterIvs.state === ClusterIvs.Valid
    property bool iviEnabled: ClusterIvi.connected && ClusterIvi.state === ClusterIvi.Valid
    anchors.fill: parent
    onIvsEnabledChanged: {
        if (ivsEnabled === false) {
            ivsWarnRect.show()
        } else {
            ivsWarnRect.hide()
        }
    }
    onIviEnabledChanged: {
        if (iviEnabled === false) {
            iviWarnRect.show()
        } else {
            iviWarnRect.hide()
        }
        animation.reset()
    }
    function init(){
        telltales.init()
        information.show()
        multiMedia.show()
        animation.reset()
        navi.reset()
    }
    Connections {
        target: ClusterIvi
        function onSkinChanged() {
            if(ClusterManager.skinList.includes(ClusterIvi.skin)){
                skinMask.setSkin(ClusterIvi.skin)
            }else{
                console.log("'"+ClusterIvi.skin+"'"+" skin does not exist!")
            }
        }
        function onNaviChanged() {
            animation.reset()
            if(navi.active===true){
                navi.item.reset()
            }
        }
    }
    Item {
        id: dashboardPartItem
        anchors.fill: parent
    }
    Item {
        id: miniDashboardPartItem
        anchors.fill: parent
        Navi{
            id:navi
            parent: mainRect
            anchors.fill: parent
            z:-100
        }
        Rectangle {
            id: blackMask
            parent: mainRect
            anchors.fill: parent
            color: skinMask.backgroundColor
            opacity: 0
            z: -10
            visible: opacity > 0
        }
        MiniDashboard {
            id: miniDashboard
            anchors.fill: parent
            enabled: ClusterIvi.navi.visible
            speed: ClusterIvs.speed
            engine: ClusterIvs.engine
            fuel: ClusterIvs.fuel
            water: ClusterIvs.water
            avgFuel: ClusterIvs.avgFuel
            maxFuel: ClusterIvs.maxFuel
            inited: true
        }
    }
    Information {
        id: information
        anchors.fill: parent
        total: ClusterIvs.total
        trip: ClusterIvs.trip
        gear: ClusterIvs.gear
        date: ClusterIvs.date
        temp: ClusterIvs.temp
        speed: ClusterIvs.speed
        avgFuel: ClusterIvs.avgFuel
        avgSpeed: ClusterIvs.avgSpeed
        adasRect.showGuide: ClusterIvs.connected&&ClusterIvs.speed<60
        avgRect.showTip: ClusterIvs.connected&&ClusterIvs.speed>80
    }
    CarInfo {
        id: carInfo
        limitSpeed: 120
        anchors.left: parent.left
        anchors.top: parent.top
        showLimit: ClusterIvs.connected&&ClusterIvs.speed>120
    }
    MultiMedia {
        id: multiMedia
        anchors.right: parent.right
        anchors.top: parent.top
        connected: mainPart.iviEnabled
        mediaPage: ClusterIvi.mediaPage
        radio.status: ClusterIvi.radio.status
        radio.frequency: ClusterIvi.radio.frequency
        music.status: ClusterIvi.music.status
        music.name: ClusterIvi.music.name
        music.author: ClusterIvi.music.author
        music.album: ClusterIvi.music.album
        music.time: ClusterIvi.music.time
        music.total: ClusterIvi.music.total
        music.image: ClusterIvi.music.image
        phone.status: ClusterIvi.phone.status
        phone.name: ClusterIvi.phone.name
        phone.nummber: ClusterIvi.phone.nummber
        phone.time: ClusterIvi.phone.time
        phone.image: ClusterIvi.phone.image
    }
    Dms {
        id: dms
        status: ClusterIvi.dms.status
        level: ClusterIvi.dms.level
        anchors.fill: parent
    }
    ConnectRect {
        id: ivsWarnRect
        parent: carInfo
        anchors.fill: parent
        text: qsTr("IVS Connecting")
    }
    ConnectRect {
        id: iviWarnRect
        parent: multiMedia
        anchors.fill: parent
        text: qsTr("IVI Connecting")
    }
    Animation {
        id: animation
        anchors.fill: parent
    }
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: 100
        height: 25
        color: skinMask.foregroundColor
        z: 10000
        visible: ClusterManager.fpsVisible
        Text {
            renderType: Text.QtRendering
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 5
            color: skinMask.backgroundColor
            text: "FPS: " + String(ClusterManager.fps)
            font.pixelSize: 20
        }
    }
}
