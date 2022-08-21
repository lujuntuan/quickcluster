﻿/*********************************************************************************
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
    id: root
    property real value: 0
    property real offset: 3
    property real scf: 0.388
    width: 897*scf
    height: 642*scf
    Image {
        source: ClusterManager.impSkinPath + "/dashboard/r_m_bg.png"
        anchors.fill: parent
    }
    CircleClip {
        id: circleClip
        anchors.fill: parent
        source: ClusterManager.impSkinPath + "/dashboard/r_m_bar.png"
        centerPoint: Qt.point(0, 180.0*root.scf)
        startAngle: (57.0+root.offset)-circleClip.getBezierCubic(0.6,0.9,root.value / 8000.0)* (66.0+root.offset)
        stopAngle: (57.0+root.offset)
        visible: !emergency
    }
    CustomText{
        id: engineText
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -125*root.scf
        text: String((value/1000.0).toFixed(1))
        font.pixelSize: 150*root.scf
        //font.bold: true
        color: skinMask.minorColor
    }
    CustomText{
        anchors.horizontalCenter: engineText.horizontalCenter
        anchors.bottom: engineText.bottom
        anchors.bottomMargin: -50*root.scf
        text: "x1000r/min"
        font.pixelSize: 50*root.scf
        //font.bold: true
        color: skinMask.primaryColor
    }
}
