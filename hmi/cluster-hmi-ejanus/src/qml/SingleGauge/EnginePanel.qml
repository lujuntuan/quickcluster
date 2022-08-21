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
    width: 703
    height: 703
    property real value: 0
    Image {
        source: ClusterManager.impSkinPath + "/singleGauge/tachometer_bg.png"
        anchors.centerIn: parent
    }
    CircleClip {
        width: 703
        height: 703
        source: ClusterManager.impSkinPath + "/singleGauge/tachometer_bar.png"
        anchors.centerIn: parent
        startAngle: 90
        stopAngle: 270 + pointerImg.rotation
        visible: !emergency
    }
    Image {
        id: pointerImg
        source: ClusterManager.impSkinPath + "/singleGauge/tachometer_bar_dot.png"
        rotation: root.value / 7000 * 243 - 120
        anchors.centerIn: parent
        visible: !emergency
    }
    Repeater {
        model: 8
        EngineNumber {
            value: index * 1000
            engineValue: root.value
            cDistance: 220
            source: ClusterManager.impSkinPath + "/singleGauge/gauge_num_" + String(
                        (value / 1000).toFixed(0)) + ".png"
        }
    }
}
