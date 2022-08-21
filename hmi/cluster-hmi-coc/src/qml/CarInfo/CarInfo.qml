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

Item{
    id:carInfo
    width: 450
    height: 140
    property int limitSpeed: 0
    property bool showLimit: false
    Image{
        id:limitRect
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        width: 80
        height: 80
        source: ClusterManager.impSkinPath + "/limit/limit_red.png"
        visible: carInfo.limitSpeed>0 && carInfo.showLimit
        smooth: true
        antialiasing: true
        opacity: 0
        SequentialAnimation on opacity{
            id:limitAni
            loops: Animation.Infinite
            running: limitRect.visible
            NumberAnimation{
                easing.type: Easing.InOutQuad
                to: 1
                duration: 500
            }
            NumberAnimation{
                easing.type: Easing.InOutQuad
                to: 0
                duration: 500
            }
        }
        Text{
            renderType: Text.QtRendering
            verticalAlignment: Text.AlignVCenter
            anchors.centerIn: parent
            text: String(carInfo.limitSpeed)
            font.pixelSize: 35
            color: "black"
        }
    }
}
