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
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height / 2 - height + 10
        spacing: 0
        ImageClip {
            id: a1
            width: 110
            height: 129
            source: ClusterManager.impSkinPath + "/singleGauge/digital.png"
            index: root.value / 100
            visible: index > 0
        }
        ImageClip {
            id: a2
            width: 110
            height: 129
            source: ClusterManager.impSkinPath + "/singleGauge/digital.png"
            index: root.value / 10 % 10
            visible: index > 0 || a1.visible
        }
        ImageClip {
            id: a3
            width: 110
            height: 129
            source: ClusterManager.impSkinPath + "/singleGauge/digital.png"
            index: root.value % 10
        }
    }
    Image {
        id: kmImage
        source: ClusterManager.impSkinPath + "/singleGauge/km_hour.png"
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height / 2 + height / 2 + 2
    }
}
