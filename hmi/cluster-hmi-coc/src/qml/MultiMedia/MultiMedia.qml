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
import "../Common"

Item {
    id: multiMedia
    width: 450
    height: 140
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
            rect.show()
        } else {
            rect.hide()
        }
    }
    onMediaPageChanged: {
        switchPage()
    }
    function show() {
        currentItem.show = true
    }
    function hide() {
        currentItem.show = false
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
    Item {
        id: rect
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
            rect.opacity = 1
        }
        function hide() {
            rect.opacity = 0
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
}
