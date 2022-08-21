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
    property real avg: 0
    property real max: 0
    property real lesskm: avg > 0 ? value / avg * 100 : 0
    Image {
        source: ClusterManager.impSkinPath + "/singleGauge/oil_bg.png"
    }
    Image {
        source: ClusterManager.impSkinPath + "/singleGauge/oil_bar_red.png"
        visible: root.value < 5
    }
    CircleClip {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 704
        height: 704
        source: ClusterManager.impSkinPath + "/singleGauge/oil_bar_blue.png"
        startAngle: 141
        stopAngle: 141 + root.value / root.max * 85
        visible: root.value >= 5
    }
    Image {
        source: ClusterManager.impSkinPath + "/singleGauge/oil_bar_line.png"
    }
    Image {
        id: backImg5
        source: ClusterManager.impSkinPath + "/singleGauge/oil_bar_line_txt.png"
    }
    Image {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 20 + 3
        source: root.value
                >= 15 ? ClusterManager.impSkinPath
                        + "/singleGauge/icon_oil_normal.png" : ClusterManager.impSkinPath
                        + "/singleGauge/icon_oil_deficiency.png"
    }
    Row {
        anchors.right: parent.left
        anchors.rightMargin: -60
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        spacing: 2
        height: 58
        ImageClip {
            id: a1
            width: 19
            height: 58
            source: ClusterManager.impSkinPath + "/singleGauge/oil_water_19_58.png"
            index: lesskm / 100
            visible: index > 0
        }
        ImageClip {
            id: a2
            width: 19
            height: 58
            source: ClusterManager.impSkinPath + "/singleGauge/oil_water_19_58.png"
            index: lesskm / 10 % 10
            visible: index > 0 || a1.visible
        }
        ImageClip {
            id: a3
            width: 19
            height: 58
            source: ClusterManager.impSkinPath + "/singleGauge/oil_water_19_58.png"
            index: lesskm % 10
        }
        Item {
            width: 29 + 5
            height: 58
            Image {
                anchors.right: parent.right
                width: 29
                height: 58
                source: ClusterManager.impSkinPath + "/singleGauge/oil_km_h.png"
            }
        }
    }
}
