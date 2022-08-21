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

SlideItem {
    id: normal
    width: parent.width
    height: parent.height
    Image {
        id: img
        source: "qrc:/qml/image/logo.png"
        anchors.centerIn: parent
        scale: 0.8
        anchors.verticalCenterOffset: -20
        antialiasing: true
        transform: [
            Scale {
                xScale: 1.1
                yScale: 0.9
                origin.x: 0
                origin.y: img.height / 2
            },
            Rotation {
                id: rotate
                axis.x: 0
                axis.y: 1
                axis.z: 0
                origin.x: 0
                origin.y: img.height / 2
                angle: -40
            }
        ]
    }
}
