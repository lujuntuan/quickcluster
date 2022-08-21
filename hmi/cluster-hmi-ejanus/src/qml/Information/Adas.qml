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
    id: adas
    width: rect.width
    height: rect.height
    property int speed: 0
    onSpeedChanged: {
        if (speed < 20) {
            lineSprite.frameRate = 50
        } else if (speed < 40) {
            lineSprite.frameRate = 75
        } else if (speed < 60) {
            lineSprite.frameRate = 100
        } else if (speed < 80) {
            lineSprite.frameRate = 142
        } else if (speed < 100) {
            lineSprite.frameRate = 162
        } else if (speed < 120) {
            lineSprite.frameRate = 200
        } else if (speed < 140) {
            lineSprite.frameRate = 250
        } else if (speed < 160) {
            lineSprite.frameRate = 310
        } else if (speed < 180) {
            lineSprite.frameRate = 330
        } else {
            lineSprite.frameRate = 420
        }
    }
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
    Image {
        id: rect
        source: ClusterManager.impSkinPath + "/adas/rode_01_bg.png"
        opacity: 0
        y: rect.height
        clip: true
        AnimatedSprite {
            id: lineSprite
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            frameWidth: 384
            frameHeight: 284
            width: frameWidth
            height: frameHeight
            frameCount: 20
            frameSync: false
            frameRate: 0
            interpolate: true
            loops: Animation.Infinite
            source: "qrc:/" + ClusterManager.skin + "/adas/line.png"
            running: adas.visible && adas.speed !== 0
            scale: 1.2
            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                }
            }
        }
        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 35
            source: ClusterManager.impSkinPath + "/adas/car_01.png"
        }
    }
}
