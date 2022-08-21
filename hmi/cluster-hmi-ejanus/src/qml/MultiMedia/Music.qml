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

SlideItem {
    id: music
    width: parent.width
    height: parent.height
    enum MusicStatus {
        STOPED = 0,
        PLAYING = 1,
        PAUSING = 2
    }
    property int status: Music.STOPED
    property string name: ""
    property string author: ""
    property string album: ""
    property int time: 0
    property int total: 0
    property var image: {
        "source": "",
        "cache": false
    }
    onStatusChanged: {
        fixMusic()
    }
    onTimeChanged: {
        fixMusic()
    }
    onTotalChanged: {
        fixMusic()
    }
    onImageChanged: {
        fixImage()
    }
    function fixMusic() {
        if (music.status === Music.STOPED) {
            imgBar.x = 0
            timeText.text = "00:00 / 00:00"
            return
        }
        var p = 0
        if (total > 0) {
            p = parseFloat(time) / total
        }
        imgBar.x = p * imgLine.width - imgBar.width / 2
        var t_time = new Date(1970, 1, 1, 0, time / 60, time % 60)
        var t_total = new Date(1970, 1, 1, 0, total / 60, total % 60)
        timeText.text = t_time.toLocaleTimeString(
                    Qt.locale("en_US"),
                    "mm:ss") + " / " + t_total.toLocaleTimeString(
                    Qt.locale("en_US"), "mm:ss")
    }
    function fixImage() {
        if (music.image !== undefined) {
            if (music.image.cache !== undefined) {
                if (music.image.cache === true) {
                    return
                }
            }
        }
        var source = music.image.source
        if (rect.flag === 0) {
            img_new.source = source
            slide_new.show = true
            slide_old.show = false
            rect.flag = 1
        } else {
            img_old.source = source
            slide_old.show = true
            slide_new.show = false
            rect.flag = 0
        }
    }
    Image {
        id: imgSelect
        source: ClusterManager.impSkinPath + "/music/pic_02.png"
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -70
        scale: music.status === Music.PLAYING ? 1 : 1.03
        antialiasing: true
        SequentialAnimation on scale {
            NumberAnimation {
                easing.type: Easing.InOutQuad
                to: 1.0
                duration: 500
            }
            NumberAnimation {
                easing.type: Easing.InOutQuad
                to: 1.06
                duration: 500
            }
            loops: Animation.Infinite
            running: music.status === Music.PLAYING && music.visible
        }
    }
    Item {
        id: rect
        width: 160
        height: 160
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -70
        clip: true
        property int flag: 0
        SlideItem {
            id: slide_old
            width: parent.width
            height: parent.height
            direct: moveDirect
            show: true
            Rectangle {
                anchors.fill: parent
                antialiasing: true
                color: Qt.rgba(0.1, 0.1, 0.1, 1)
            }
            Image {
                source: ClusterManager.impSkinPath + "/music/music_null.png"
                anchors.centerIn: parent
                antialiasing: true
            }
            Image {
                id: img_old
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                antialiasing: true
            }
        }
        SlideItem {
            id: slide_new
            width: rect.width
            height: rect.height
            direct: moveDirect
            show: false
            Rectangle {
                anchors.fill: parent
                antialiasing: true
                color: Qt.rgba(0.1, 0.1, 0.1, 1)
            }
            Image {
                source: ClusterManager.impSkinPath + "/music/music_null.png"
                anchors.centerIn: parent
                antialiasing: true
            }
            Image {
                id: img_new
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                antialiasing: true
            }
        }
    }
    Rectangle {
        id: pauseRect
        antialiasing: true
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -70
        width: 100
        height: 100
        radius: 100
        color: Qt.rgba(0, 0, 0, 1)
        opacity: 0.9
        visible: music.status === Music.PAUSING
        Rectangle {
            antialiasing: true
            width: 10
            height: 50
            x: parent.width / 3 - width / 3
            anchors.verticalCenter: parent.verticalCenter
        }
        Rectangle {
            antialiasing: true
            width: 10
            height: 50
            x: parent.width / 3 * 2 - width / 3 * 2
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    ScrollText {
        width: 350
        height: 60
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 45
        font.pixelSize: 30
        text: music.name
    }
    ScrollText {
        width: 350
        height: 30
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 85
        font.pixelSize: 20
        opacity: 0.8
        text: music.author + (music.album === "" ? "" : " <" + music.album + ">")
    }
    Image {
        id: imgLine
        source: ClusterManager.impSkinPath + "/music/music_line.png"
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 115
        antialiasing: true
        Rectangle {
            color: Qt.rgba(0.7, 0.7, 0.7, 0.7)
            radius: height
            anchors.verticalCenter: parent.verticalCenter
            width: imgBar.x + imgBar.width / 2
            height: 4
            x: 0
        }
        Image {
            id: imgBar
            source: ClusterManager.impSkinPath + "/music/music_bar.png"
            anchors.verticalCenter: parent.verticalCenter
            antialiasing: true
            x: 0
            Behavior on x {
                NumberAnimation {
                    easing.type: Easing.OutCubic
                    duration: 200
                }
            }
        }
    }
    CustomText {
        id: timeText
        anchors.top: imgLine.bottom
        anchors.topMargin: 5
        anchors.right: imgLine.right
        text: "00:00 / 00:00"
        opacity: 0.8
        font.pixelSize: 20
    }
}
