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
    id: root
    width: 421
    height: 185
    property real value: 0
    property real offset: 0
    property real scf: 1
    Image {
        source: ClusterManager.impSkinPath + "/water/bg.png"
    }
    CircleClip {
        id: circleClip
        anchors.fill: parent
        source: ClusterManager.impSkinPath + "/water/bg_bar.png"
        centerPoint: Qt.point(-width, -height)
        startAngle: (36.2+root.offset)-circleClip.getBezierCubic(0.6,0.9,root.value / 100.0)* (21.8+root.offset)
        stopAngle: (36.2+root.offset)
        visible: !emergency
    }
    Image {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 100
        anchors.verticalCenterOffset: -10
        source: {
            if(value<=-20||value>=100){
                return ClusterManager.impSkinPath + "/water/icon_red.png"
            }else if(value<=0||value>=80){
                return ClusterManager.impSkinPath + "/water/icon_yellow.png"
            }else{
                return ClusterManager.impSkinPath + "/water/icon_normal.png"
            }
        }
    }
    CustomText{
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 100
        anchors.verticalCenterOffset: 40
        font.pixelSize: 30
        text: String(root.value.toFixed(0)) +" °c"
        color: skinMask.primaryColor
    }
}
