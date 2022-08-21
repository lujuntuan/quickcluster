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
    id: tripRect
    width: rect.width
    height: rect.height
    property real total: -1
    property real trip: -1
    ParallelAnimation {
        id: ani
        NumberAnimation {
            id: ani1
            target: rect
            property: "opacity"
            duration: 500
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            id: ani2
            target: rect
            property: "y"
            duration: 500
            easing.type: Easing.OutCubic
        }
    }
    function show() {
        ani1.from = 0
        ani1.to = 1
        ani2.from = rect.height
        ani2.to = 0
        ani.restart()
    }
    function hide() {
        ani1.from = 1
        ani1.to = 0
        ani2.from = 0
        ani2.to = rect.height
        ani.restart()
    }
    Column {
        id:rect
        width: 300
        opacity: 0
        y: rect.height
        CustomText {
            width: 300
            height: 50
            font.pixelSize: 30
            rightPadding: 10
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: CustomText.AlignHCenter
            text: "Trip: "+(tripRect.trip < 0 ? "---" : String(tripRect.trip.toFixed(1))+" km")
            leftPadding: 5
            color: skinMask.primaryColor
        }
        CustomText {
            width: 300
            height: 50
            font.pixelSize: 30
            rightPadding: 10
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: CustomText.AlignHCenter
            text: "Total: "+(tripRect.total < 0 ? "---" : String(tripRect.total.toFixed(0)) +" km")
            leftPadding: 5
            color: skinMask.primaryColor
        }
    }
}
