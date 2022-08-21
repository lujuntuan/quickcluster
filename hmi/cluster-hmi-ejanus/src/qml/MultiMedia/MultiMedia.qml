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
    id: multiMedia
    width: 500
    height: 450
    clip: true
    enum MediaPage {
        NORMAL = 0,
        RADIO = 1,
        MUSIC = 2,
        PHONE = 3
    }
    property bool connected: false
    property int mediaPage: MultiMedia.NORMAL
    property int moveDirect: SlideItem.LEFT
    property alias radio: radio
    property alias music: music
    property alias phone: phone
    property SlideItem currentItem: normal
    onConnectedChanged: {
        if (connected === true) {
            mediaRect.show()
            iviWarnRect.hide()
        } else {
            mediaRect.hide()
            iviWarnRect.show()
        }
    }
    onMediaPageChanged: {
        switchPage()
    }
    function show() {
        currentItem.show = true
        maskImg.opacity = 0.5
    }
    function hide() {
        currentItem.show = false
        maskImg.opacity = 0
    }
    function switchPage() {
        switch (multiMedia.mediaPage) {
        case MultiMedia.NORMAL:
            currentItem = normal
            normal.show = true
            radio.show = false
            music.show = false
            phone.show = false
            break
        case MultiMedia.RADIO:
            currentItem = radio
            normal.show = false
            radio.show = true
            music.show = false
            phone.show = false
            break
        case MultiMedia.MUSIC:
            currentItem = music
            normal.show = false
            radio.show = false
            music.show = true
            phone.show = false
            break
        case MultiMedia.PHONE:
            currentItem = phone
            normal.show = false
            radio.show = false
            music.show = false
            phone.show = true
            break
        default:
            currentItem = normal
            normal.show = true
            radio.show = false
            music.show = false
            phone.show = false
            break
        }
    }
    Image {
        id: maskImg
        source: ClusterManager.impSkinPath + "/common/mask_r.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        z: 100
        visible: opacity > 0
        opacity: 0
        Behavior on opacity {
            NumberAnimation {
                easing.type: Easing.OutCubic
                duration: 500
            }
        }
    }
    Item {
        id: rect
        anchors.fill: parent
        transform: [
            Scale {
                xScale: 1.15
                yScale: 0.9
                origin.x: 0
                origin.y: rect.height / 2
            },
            Rotation {
                id: rotate
                axis.x: 0
                axis.y: 1
                axis.z: 0
                origin.x: 0
                origin.y: rect.height / 2
                angle: -60
            }
        ]
        Item {
            id: mediaRect
            anchors.fill: parent
            opacity: 0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation {
                    easing.type: Easing.OutCubic
                    duration: 500
                }
            }
            function show() {
                mediaRect.opacity = 1
            }
            function hide() {
                mediaRect.opacity = 0
            }
            Normal {
                id: normal
                show: false
                direct: multiMedia.moveDirect
            }
            Radio {
                id: radio
                show: false
                direct: multiMedia.moveDirect
            }
            Music {
                id: music
                show: false
                direct: multiMedia.moveDirect
            }
            Phone {
                id: phone
                show: false
                direct: multiMedia.moveDirect
            }
        }
        IviWarnRect {
            id: iviWarnRect
            anchors.fill: parent
        }
    }
}
