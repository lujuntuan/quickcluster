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
    id: phone
    width: parent.width
    height: parent.height
    enum PhoneStatus {
        HANGUP = 0,
        OUTGOING = 1,
        INCOMMING = 2,
        TALKING = 3
    }
    property int status: Phone.HANGUP
    property string name: ""
    property string nummber: ""
    property int time: 0
    property var image: {
        "source": "",
        "cache": false
    }
    function fixPhone() {
        var t_time = new Date(1970, 1, 1, 0, time / 60, time % 60)
        switch (status) {
        case Phone.HANGUP:
            phoneText.text = "HANGUP"
            break
        case Phone.OUTGOING:
            phoneText.text = "OUTGOING"
            break
        case Phone.INCOMMING:
            phoneText.text = "INCOMMING"
            break
        case Phone.TALKING:
            phoneText.text = "TALKING" + "\n" + t_time.toLocaleTimeString(
                        Qt.locale("en_US"), "mm:ss")
            break
        }
    }
    onStatusChanged: {
        fixPhone()
    }
    onTimeChanged: {
        fixPhone()
    }
    onImageChanged: {
        if (phone.image !== undefined) {
            if (phone.image.cache !== undefined) {
                if (phone.image.cache === true) {
                    return
                }
            }
        }
        if (phone.image.source === undefined) {
            img.source = ""
        } else {
            img.source = phone.image.source
        }
    }
    Item{
        id: rect
        width: 100
        height: 100
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter
        visible: false
        Rectangle {
            anchors.fill: parent
            color: skinMask.decorateColor
        }
        Image {
            anchors.fill: parent
            source: ClusterManager.impSkinPath + "/phone/pic.png"
        }
        Image {
            id: img
            source: ""
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
        }
    }
    OpacityMask {
        anchors.fill: rect
        source: rect
        maskSource: Rectangle {
            width: rect.width
            height: rect.width
            radius: width/2
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
        text: phone.name === "" ? phone.nummber : (phone.nummber === "" ? phone.name : (phone.name + " (" + phone.nummber + ")"))
        color: skinMask.primaryColor
    }
    CustomText {
        id: phoneText
        anchors.left: rect.right
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 25
        horizontalAlignment: CustomText.AlignHCenter
        font.pixelSize: 20
        text: "HANGUP"
        opacity: 0.8
        color: skinMask.primaryColor
    }
    DotsItem {
        color: skinMask.primaryColor
        radius: 3
        interval: 250
        count: 4
        spacing: 3
        anchors.top: phoneText.top
        anchors.topMargin: phoneText.lineCount
                           > 0 ? (phoneText.height / phoneText.lineCount) / 2 : 0
        anchors.left: phoneText.right
        anchors.leftMargin: 5
        reverse: false
        still: phone.status === Phone.HANGUP
    }
}
