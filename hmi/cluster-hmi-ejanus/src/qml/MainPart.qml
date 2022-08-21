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
import "CarInfo"
import "MultiMedia"
import "DoubleGauge"
import "Dms"
import "Common"

Item {
    id: mainPart
    property bool ivsEnabled: ClusterIvs.connected
                              && ClusterIvs.state === ClusterIvs.Valid
    property bool iviEnabled: ClusterIvi.connected
                              && ClusterIvi.state === ClusterIvi.Valid
    anchors.fill: parent
    onIvsEnabledChanged: {
        if (ivsEnabled === false) {
            ivsWarnRect.show()
        } else {
            ivsWarnRect.hide()
        }
    }
    onIviEnabledChanged: {
        animation.reset()
        //skinMask.configSkin()
    }
    function init(){
        telltales.init()
        information.show()
        carInfo.show()
        multiMedia.show()
        animation.reset()
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
        }
    }
    Item {
        id: singleGaugePartItem
        anchors.fill: parent
        Information {
            id: information
            anchors.fill: parent
            total: ClusterIvs.total
            trip: ClusterIvs.trip
            gear: ClusterIvs.gear
            date: ClusterIvs.date
            temp: ClusterIvs.temp
            speed: ClusterIvs.speed
        }
        CarInfo {
            id: carInfo
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 50
            tirePanel.tireFrontLeft: ClusterIvs.tireFrontLeft
            tirePanel.tireFrontRight: ClusterIvs.tireFrontRight
            tirePanel.tireBehindLeft: ClusterIvs.tireBehindLeft
            tirePanel.tireBehindRight: ClusterIvs.tireBehindRight
            avgSpeedPanel.speed: ClusterIvs.avgSpeed
            running: mainPart.ivsEnabled
        }
        MultiMedia {
            id: multiMedia
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 50
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
    }
    Item {
        id: doubleGaugePartItem
        anchors.fill: parent
        Rectangle {
            id: blackMask
            parent: mainRect
            anchors.fill: parent
            color: "black"
            opacity: 0
            z: -10
            visible: opacity > 0
        }
        DoubleGauge {
            id: doubleGauge
            anchors.fill: parent
            speed: ClusterIvs.speed
            engine: ClusterIvs.engine
            fuel: ClusterIvs.fuel
            water: ClusterIvs.water
            avgFuel: ClusterIvs.avgFuel
            maxFuel: ClusterIvs.maxFuel
            gear: ClusterIvs.gear
            total: ClusterIvs.total
            trip: ClusterIvs.trip
            date: ClusterIvs.date
            temp: ClusterIvs.temp
            leftSignal: ClusterIvs.telltalesMap["icon_left_signal"] !== 0
            rightSignal: ClusterIvs.telltalesMap["icon_right_signal"] !== 0
            enabled: ClusterIvi.navi.visible
        }
    }
    Dms {
        id: dms
        status: ClusterIvi.dms.status
        level: ClusterIvi.dms.level
        anchors.fill: parent
    }
    IvsWarnRect {
        id: ivsWarnRect
        anchors.fill: parent
    }
    Animation {
        id: animation
    }
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: 100
        height: 25
        color: "white"
        z: 10000
        visible: ClusterManager.fpsVisible
        CustomText {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 5
            color: "black"
            text: "FPS: " + String(ClusterManager.fps)
            font.pixelSize: 20
        }
    }
}
