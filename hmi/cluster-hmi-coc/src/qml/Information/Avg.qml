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
    id: avg
    property real avgFuel: 0
    property real avgSpeed: 0
    property bool showTip: false
    width: 300
    height: 200
    function show() {
        avg.visible=true
    }
    function hide() {
        avg.visible=false
    }
    Rectangle{
        id:rect
        anchors.fill: parent
        color: "transparent"
        radius: 10
        opacity: avg.showTip&&avg.visible?1:0
        scale: avg.showTip&&avg.visible?1:1.2
        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }
        Column{
            anchors.fill: parent
            Row{
                padding: 20
                spacing: 10
                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    source: ClusterManager.impSkinPath + "/avg/avg_fuel.png"
                }
                CustomText {
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 30
                    color: skinMask.primaryColor
                    text: String(avg.avgFuel.toFixed(1))+" L/100km"
                }
            }
            Row{
                padding: 20
                spacing: 10
                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    source: ClusterManager.impSkinPath + "/avg/avg_speed.png"
                }
                CustomText {
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 30
                    color: skinMask.primaryColor
                    text: String(avg.avgSpeed.toFixed(0))+" km/h"
                }
            }
        }
    }
}
