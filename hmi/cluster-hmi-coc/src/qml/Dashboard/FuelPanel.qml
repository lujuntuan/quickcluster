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
    property real avgValue:0
    property real maxValue:0
    property real offset: 0
    property real scf: 1
    Image {
        source: ClusterManager.impSkinPath + "/fuel/bg.png"
    }
    CircleClip {
        id: circleClip
        anchors.fill: parent
        source: ClusterManager.impSkinPath + "/fuel/bg_bar.png"
        centerPoint: Qt.point(width*2,-height)
        startAngle: (143.8+root.offset)
        stopAngle: (root.maxValue>0&&root.avgValue>0)?((143.8+root.offset)+circleClip.getBezierCubic(0.6,0.9,root.value / root.maxValue)* (21.8+root.offset)):0
        visible: !emergency
    }
    Image {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: -100
        anchors.verticalCenterOffset: -10
        source: {
            if(value<=5){
                return ClusterManager.impSkinPath + "/fuel/icon_red.png"
            }else if(value<=10){
                return ClusterManager.impSkinPath + "/fuel/icon_yellow.png"
            }else{
                return ClusterManager.impSkinPath + "/fuel/icon_normal.png"
            }
        }
    }
    CustomText{
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: -100
        anchors.verticalCenterOffset: 40
        font.pixelSize: 30
        text: (root.maxValue>0&&root.avgValue>0)?(String((100.0*root.value/root.avgValue).toFixed(0)) +" km"):"0 km"
        color: skinMask.primaryColor
    }
}
