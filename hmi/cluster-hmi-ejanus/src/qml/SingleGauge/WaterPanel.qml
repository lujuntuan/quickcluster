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
    width: 200
    height: 494
    property real value: 0
    Image {
        id: backImg
        source: ClusterManager.impSkinPath + "/singleGauge/water_temperature_bg.png"
    }
    CircleClip {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 704
        height: 704
        source: ClusterManager.impSkinPath + "/singleGauge/water_temperature_bar_blue.png"
        startAngle: 45 - root.value / 90 * 85
        stopAngle: 40
        visible: root.value >= 10 && root.value <= 90
    }
    Image {
        id: backImg3
        source: ClusterManager.impSkinPath + "/singleGauge/water_temperature_bar_green.png"
        visible: root.value < 10
    }
    Image {
        id: backImg4
        source: ClusterManager.impSkinPath + "/singleGauge/water_temperature_bar_red.png"
        visible: root.value > 90
    }
    Image {
        id: backImg5
        source: ClusterManager.impSkinPath + "/singleGauge/water_temperature_line.png"
    }
    Image {
        id: backImg6
        source: ClusterManager.impSkinPath + "/singleGauge/water_temperature_line_txt.png"
    }
    Image {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 20 + 8
        source: root.value >= 10 && root.value
                <= 100 ? ClusterManager.impSkinPath
                         + "/singleGauge/icon_water_normal.png" : ClusterManager.impSkinPath
                         + "/singleGauge/icon_water_fault.png"
    }
    Row {
        anchors.right: parent.right
        anchors.rightMargin: -30
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        spacing: 2
        height: 58
        Image {
            width: 19
            height: 58
            source: ClusterManager.impSkinPath + "/singleGauge/fushu.png"
            visible: root.value < 0
        }
        ImageClip {
            id: a1
            width: 19
            height: 58
            source: ClusterManager.impSkinPath + "/singleGauge/oil_water_19_58.png"
            index: Math.abs(root.value) / 100
            visible: index > 0
        }
        ImageClip {
            id: a2
            width: 19
            height: 58
            source: ClusterManager.impSkinPath + "/singleGauge/oil_water_19_58.png"
            index: Math.abs(root.value) / 10 % 10
            visible: index > 0 || a1.visible
        }
        ImageClip {
            id: a3
            width: 19
            height: 58
            source: ClusterManager.impSkinPath + "/singleGauge/oil_water_19_58.png"
            index: Math.abs(root.value) % 10
        }
        Item {
            width: 29 + 5
            height: 58
            Image {
                anchors.right: parent.right
                width: 29
                height: 58
                source: ClusterManager.impSkinPath + "/singleGauge/water_c.png"
            }
        }
    }
}
