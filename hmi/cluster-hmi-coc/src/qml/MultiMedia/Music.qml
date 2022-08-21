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
            //imgBar.x = 0
            timeText.text = "00:00 / 00:00"
            return
        }
        var p = 0
        if (total > 0) {
            p = parseFloat(time) / total
        }
        //imgBar.x = p * imgLine.width - imgBar.width / 2
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
    Item {
        id: rect
        width: 100
        height: 100
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter
        visible: false
        property int flag: 0
        SlideItem {
            id: slide_old
            width: parent.width
            height: parent.height
            direct: moveDirect
            show: true
            Rectangle {
                anchors.fill: parent
                color: skinMask.decorateColor
            }
            Image {
                anchors.fill: parent
                source: ClusterManager.impSkinPath + "/music/pic.png"
            }
            Image {
                id: img_old
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
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
                color: skinMask.decorateColor
            }
            Image {
                anchors.fill: parent
                source: ClusterManager.impSkinPath + "/music/pic.png"
            }
            Image {
                id: img_new
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
            }
        }
    }
    OpacityMask {
        id:maskRect
        anchors.fill: rect
        source: rect
        maskSource: Rectangle{
            width: rect.width
            height: rect.height
            radius: rect.width/2
        }
    }
    Rectangle {
        id: pauseRect
        anchors.centerIn: rect
        width: rect.width/2
        height: rect.height/2
        radius: width/2
        color: skinMask.backgroundColor
        opacity: 0.9
        visible: music.status === Music.PAUSING
        Rectangle {
            width: parent.width/8
            height: parent.height/2
            x: parent.width / 3 - width / 3
            anchors.verticalCenter: parent.verticalCenter
            color: skinMask.foregroundColor
        }
        Rectangle {
            width: parent.width/8
            height: parent.height/2
            x: parent.width / 3 * 2 - width / 3 * 2
            anchors.verticalCenter: parent.verticalCenter
            color: skinMask.foregroundColor
        }
    }
    ScrollText {
        width: 300
        height: 50
        anchors.left: rect.right
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -30
        textToCenter: false
        font.pixelSize: 25
        text: music.name
        color: skinMask.primaryColor
    }
    ScrollText {
        width: 300
        height: 30
        anchors.left: rect.right
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 10
        textToCenter: false
        font.pixelSize: 20
        opacity: 0.8
        text: music.author + (music.album === "" ? "" : " <" + music.album + ">")
        color: skinMask.primaryColor
    }
    CustomText {
        id: timeText
        anchors.left: rect.right
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 40
        text: "00:00 / 00:00"
        color: skinMask.primaryColor
        opacity: 0.8
        font.pixelSize: 20
    }
}
