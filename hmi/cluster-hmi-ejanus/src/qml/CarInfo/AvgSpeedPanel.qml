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

SlideItem{
    id:avgSpeedPanel
    width: parent.width
    height: parent.height
    property real speed: 0
    property bool running: false
    DrawLine{
        id: drawLine
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 0
        anchors.horizontalCenterOffset: 50
        width: 320
        height: 220
        dymasic :true
        running: avgSpeedPanel.visible&&avgSpeedPanel.running
    }
    CustomText{
        text: qsTr("AVG Speed")
        anchors.left: drawLine.left
        anchors.bottom: drawLine.top
        anchors.leftMargin: 5
        anchors.bottomMargin: 5
        font.pixelSize: 28
    }
    CustomText{
        anchors.right: drawLine.right
        anchors.bottom: drawLine.top
        anchors.rightMargin: 5
        anchors.bottomMargin: 5
        text: String(avgSpeedPanel.speed.toFixed(0))+" km/h"
        font.pixelSize: 28
        horizontalAlignment: Text.AlignRight
    }
    CustomText{
        text: "20"
        anchors.top: drawLine.top
        anchors.topMargin: -height/2
        anchors.right: drawLine.left
        anchors.rightMargin: 10
        x: 0
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 24
        CustomText{
            text: "L/100km"
            anchors.top: parent.bottom
            anchors.right: parent.right
            font.pixelSize: 18
            opacity: 0.5
        }
    }
    CustomText{
        text: "0"
        anchors.bottom: drawLine.bottom
        anchors.bottomMargin: -height/2
        anchors.right: drawLine.left
        anchors.rightMargin: 10
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 24
    }
    CustomText{
        text: qsTr("AVG : 9.7")
        anchors.verticalCenter: drawLine.verticalCenter
        anchors.right: drawLine.left
        anchors.rightMargin: 5
        font.pixelSize: 20
        verticalAlignment: Text.AlignVCenter
    }
}
