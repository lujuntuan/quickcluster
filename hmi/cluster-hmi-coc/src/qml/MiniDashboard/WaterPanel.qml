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
    width: 170
    height: 76
    property real value: 0
    property real offset: 0
    property real scf: 1
    Image {
        source: ClusterManager.impSkinPath + "/water/bg_m.png"
    }
    CircleClip {
        id: circleClip
        anchors.fill: parent
        source: ClusterManager.impSkinPath + "/water/bg_bar_m.png"
        centerPoint: Qt.point(-width, -height)
        startAngle: (36.2+root.offset)-circleClip.getBezierCubic(0.6,0.9,root.value / 100.0)* (21.8+root.offset)
        stopAngle: (36.2+root.offset)
        visible: !emergency
    }
    Image {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 40
        anchors.verticalCenterOffset: 0
        source: {
            if(value<=-20||value>=100){
                return ClusterManager.impSkinPath + "/water/icon_red_m.png"
            }else if(value<=0||value>=80){
                return ClusterManager.impSkinPath + "/water/icon_yellow_m.png"
            }else{
                return ClusterManager.impSkinPath + "/water/icon_normal_m.png"
            }
        }
    }
    CustomText{
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 40
        anchors.verticalCenterOffset: 35
        font.pixelSize: 20
        text: String(root.value.toFixed(0)) +" °c"
        color: skinMask.primaryColor
    }
}
