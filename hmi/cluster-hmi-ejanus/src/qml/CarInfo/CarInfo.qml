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
    width: 500
    height: 450
    clip: true
    property alias tirePanel: tirePanel
    property alias avgSpeedPanel: avgSpeedPanel
    property int moveDirect: SlideItem.RIGHT
    property bool running: false
    property SlideItem currentItem: tirePanel
    onRunningChanged: {
        if(running===false){
            tirePanel.show=true
            avgSpeedPanel.show=false
            currentItem=tirePanel
        }
    }
    function show(){
        currentItem.show=true
        maskImg.opacity=0.5
    }
    function hide(){
        currentItem.show=false
        maskImg.opacity=0
    }
    Image {
        id:maskImg
        source: ClusterManager.impSkinPath+"/common/mask_l.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        z:100
        opacity: 0
        visible: opacity>0
        Behavior on opacity {
            NumberAnimation{
                easing.type: Easing.OutCubic
                duration: 500
            }
        }
    }
    Timer{
        interval: 10000
        repeat: true
        running: carInfo.running
        onTriggered: {
            if(tirePanel.visible===true){
                tirePanel.show=false
                avgSpeedPanel.show=true
                currentItem=avgSpeedPanel
            }else{
                tirePanel.show=true
                avgSpeedPanel.show=false
                currentItem=tirePanel
            }
        }
    }
    Item{
        id:rect
        anchors.fill: parent
        transform: [
            Scale{
                xScale: 1.15
                yScale: 0.9
                origin.x: rect.width
                origin.y: rect.height/2
            },
            Rotation{
                id: rotate
                axis.x: 0
                axis.y: 1
                axis.z: 0
                origin.x: rect.width
                origin.y: rect.height/2
                angle: 60
            }
        ]
        TirePanel{
            id:tirePanel
            show: false
            direct: carInfo.moveDirect
        }
        AvgSpeedPanel{
            id:avgSpeedPanel
            show: false
            direct: carInfo.moveDirect
            running: carInfo.running
        }
    }
}
