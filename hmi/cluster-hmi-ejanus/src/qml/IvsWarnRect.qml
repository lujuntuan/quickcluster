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
import "Common"

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
        anchors.verticalCenterOffset: 60
        width: 600
        height: 100
        opacity: 1
        visible: opacity > 0
        color: "black"
        border.width: 4
        border.color: warnText.color
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
            text: qsTr("IVS Connecting")
            font.pixelSize: 35
        }
        DotsItem {
            spacing: 5
            count: 4
            color: Qt.rgba(0.7, 0.7, 0.7, 1)
            radius: 5
            interval: 300
            anchors.left: warnText.right
            anchors.verticalCenter: warnText.verticalCenter
            anchors.leftMargin: 10
            anchors.verticalCenterOffset: 5
        }
    }
}
