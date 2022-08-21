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

    Image {
        id: hangupImg
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -70
        anchors.horizontalCenterOffset: -170
        source: phone.status === Phone.HANGUP ? ClusterManager.impSkinPath + "/phone/phone_hangup_pushed.png" : ClusterManager.impSkinPath + "/phone/phone_hangup_normal.png"
        antialiasing: true
    }
    Image {
        id: callImg
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -70
        anchors.horizontalCenterOffset: 170
        source: phone.status === Phone.TALKING ? ClusterManager.impSkinPath + "/phone/phone__call_pushed.png" : ClusterManager.impSkinPath + "/phone/phone__call_normal.png"
        antialiasing: true
        SequentialAnimation {
            loops: Animation.Infinite
            running: (phone.status === Phone.INCOMMING
                      || phone.status === Phone.OUTGOING) && phone.visible
            NumberAnimation {
                target: callImg
                property: "rotation"
                duration: 500
                easing.period: 0.5
                easing.amplitude: 5
                easing.type: Easing.InElastic
                from: 0
                to: 10
            }
            NumberAnimation {
                target: callImg
                property: "rotation"
                duration: 500
                easing.period: 0.5
                easing.amplitude: 5
                easing.type: Easing.OutElastic
                from: 10
                to: 0
            }
        }
    }
    DotsItem {
        color: Qt.rgba(0.8, 0.8, 0.8, 0.8)
        radius: 5
        interval: 250
        count: 4
        spacing: 2
        anchors.verticalCenter: hangupImg.verticalCenter
        anchors.left: hangupImg.right
        anchors.leftMargin: 2
        reverse: true
        still: phone.status !== Phone.HANGUP
    }
    DotsItem {
        color: Qt.rgba(0.8, 0.8, 0.8, 0.8)
        radius: 5
        interval: 250
        count: 4
        spacing: 2
        anchors.verticalCenter: callImg.verticalCenter
        anchors.right: callImg.left
        anchors.rightMargin: 2
        reverse: phone.status === Phone.INCOMMING
        still: !(phone.status === Phone.INCOMMING
                 || phone.status === Phone.OUTGOING)
    }
    Image {
        id: imgBg
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -70
        source: ClusterManager.impSkinPath + "/phone/phone_pan_bg.png"
        antialiasing: true
    }
    Image {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -70
        source: ClusterManager.impSkinPath + "/phone/phone_pan_bar.png"
        visible: phone.status === Phone.TALKING
        antialiasing: true
        rotation: 0
        RotationAnimation on rotation {
            duration: 5000
            from: 0
            to: 360
            loops: Animation.Infinite
            running: phone.status === Phone.TALKING && phone.visible
        }
    }
    Image {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -70
        source: ClusterManager.impSkinPath + "/phone/redio_people.png"
        antialiasing: true
        scale: 1.5
    }
    Rectangle {
        id: maskImg
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -70
        radius: img.width
        width: img.width
        height: img.width
        visible: false
        color: "black"
        antialiasing: true
    }
    Image {
        id: img
        width: 130
        height: img.width
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -70
        source: ""
        visible: false
        fillMode: Image.PreserveAspectFit
        antialiasing: true
    }
    OpacityMask {
        anchors.fill: img
        source: img
        maskSource: maskImg
        antialiasing: true
    }
    ScrollText {
        width: 350
        height: 60
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 60
        font.pixelSize: 30
        text: phone.name === "" ? phone.nummber : (phone.nummber === "" ? phone.name : (phone.name + " (" + phone.nummber + ")"))
    }
    CustomText {
        id: phoneText
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 120
        horizontalAlignment: CustomText.AlignHCenter
        font.pixelSize: 20
        text: "HANGUP"
        opacity: 0.8
    }
    DotsItem {
        color: Qt.rgba(0.7, 0.7, 0.7, 0.7)
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
