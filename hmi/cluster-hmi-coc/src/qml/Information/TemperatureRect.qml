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
    id: temperatureRect
    width: rect.width
    height: rect.height
    property real temp: 0
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
        ani2.from = -rect.height
        ani2.to = 0
        ani.restart()
    }
    function hide() {
        ani1.from = 1
        ani1.to = 0
        ani2.from = 0
        ani2.to = -rect.height
        ani.restart()
    }
    CustomText {
        id: rect
        height: 50
        opacity: 0
        y: -rect.height
        font.pixelSize: 35
        color: skinMask.primaryColor
        text: (temp < -100|| temp > 100) ? "--- °c" : String(temperatureRect.temp.toFixed(0)) + " °c"
    }
}
