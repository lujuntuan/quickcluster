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
    id: connectRect
    opacity: 1
    visible: opacity > 0
    property string text: ""
    Behavior on opacity {
        NumberAnimation {
            easing.type: Easing.OutCubic
            duration: 500
        }
    }
    function show() {
        connectRect.opacity = 1
    }
    function hide() {
        connectRect.opacity = 0
    }
    CustomText {
        id: warnText
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: -10
        text: connectRect.text
        font.pixelSize: 28
        font.bold: true
        color: skinMask.primaryColor
    }
    DotsItem {
        spacing: 5
        count: 4
        color: skinMask.primaryColor
        radius: 5
        interval: 300
        anchors.left: warnText.right
        anchors.verticalCenter: warnText.verticalCenter
        anchors.leftMargin: 10
        anchors.verticalCenterOffset: 5
    }
}
