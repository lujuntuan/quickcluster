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
    id: radio
    width: parent.width
    height: parent.height
    enum RadioStatus {
        CLOSED = 0,
        FM = 1,
        AM = 2
    }
    property int status: Radio.CLOSED
    property string frequency: ""
    onStatusChanged: {
        ani.restart()
    }
    ParallelAnimation {
        id: ani
        NumberAnimation {
            target: rect
            property: "scale"
            easing.type: Easing.OutCubic
            duration: 400
            from: 0.8
            to: 1
        }
        NumberAnimation {
            target: rect
            property: "opacity"
            easing.type: Easing.OutCubic
            duration: 400
            from: 0
            to: 1
        }
    }
    Item {
        id: rect
        anchors.fill: parent
        Rectangle{
            id: ico
            width: 90
            height: 90
            color: skinMask.decorateColor
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.verticalCenter: parent.verticalCenter
            radius: 18
            Image {
                id: img
                source: ClusterManager.impSkinPath + "/radio/pic.png"
                anchors.left: parent.left
                anchors.bottom: parent.bottom
            }
        }
        CustomText {
            id:numText
            font.pixelSize: 50
            text: radio.frequency
            opacity: 1
            anchors.left: ico.right
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            color: skinMask.primaryColor
        }
        CustomText {
            font.pixelSize: 30
            text: radio.status === Radio.FM ? "FM" : (radio.status === Radio.AM ? "AM" : "")
            anchors.left: numText.right
            anchors.leftMargin: 20
            anchors.verticalCenter: numText.verticalCenter
            anchors.verticalCenterOffset: -10
            color: skinMask.primaryColor
        }
        CustomText {
            font.pixelSize: 20
            text: radio.status === Radio.FM ? "MHz" : (radio.status === Radio.AM ? "KHz" : "")
            opacity: 1
            anchors.left: numText.right
            anchors.leftMargin: 20
            anchors.verticalCenter: numText.verticalCenter
            anchors.verticalCenterOffset: 20
            color: skinMask.primaryColor
        }
    }
}
