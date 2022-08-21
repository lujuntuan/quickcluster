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
    id: ivsWarnRect
    function show() {
        rect.opacity = 1
    }
    function hide() {
        rect.opacity = 0
    }
    Rectangle {
        id: rect
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 0
        width: 380
        height: 70
        opacity: 1
        visible: opacity > 0
        color: "black"
        border.width: 4
        border.color: warnText.color
        antialiasing: true
        Behavior on opacity {
            NumberAnimation {
                easing.type: Easing.OutCubic
                duration: 500
            }
        }
        CustomText {
            id: warnText
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -10
            text: qsTr("IVI Connecting")
            font.pixelSize: 25
        }
        DotsItem {
            spacing: 5
            count: 4
            color: Qt.rgba(0.7, 0.7, 0.7, 1)
            radius: 4
            interval: 300
            anchors.left: warnText.right
            anchors.verticalCenter: warnText.verticalCenter
            anchors.leftMargin: 10
            anchors.verticalCenterOffset: 5
        }
    }
}
