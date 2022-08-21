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
    id: temperatureRect
    width: rect.width
    height: rect.height
    property int temp: 0
    property bool cold: temp < 5
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
    Row {
        id: rect
        spacing: 20
        height: temperatureText.height
        opacity: 0
        y: -rect.height
        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: ClusterManager.impSkinPath + "/common/xuehua.png"
            visible: temperatureRect.cold
            antialiasing: true
            RotationAnimation on rotation {
                duration: 5000
                from: 0
                to: 360
                loops: Animation.Infinite
                running: temperatureRect.cold
            }
        }
        CustomText {
            id: temperatureText
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 30
            text: (temperatureRect.temp < -100
                   || temperatureRect.temp > 100) ? "--- °C" : String(
                                                        temperatureRect.temp) + " °C"
        }
    }
}
