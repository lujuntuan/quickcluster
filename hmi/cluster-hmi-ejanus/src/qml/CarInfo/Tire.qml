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
    id:tire
    width: img.width
    height: img.height
    property int temp: 0
    property real pressure: 0
    property int type: 0
    Image {
        id:img
        readonly property int status: {
            if(pressure<=0){
                return -1
            }
            if(tire.pressure<1.5||tire.pressure>2.8){
                if(tire.pressure<1.0||tire.pressure>3.2){
                    return 2
                }else{
                    return 1
                }
            }
            return 0
        }
        antialiasing: true
        visible: img.status>0
        source: img.status===2?ClusterManager.impSkinPath+"/tirePressure/tire_pressure_overload.png":ClusterManager.impSkinPath+"/tirePressure/tire_pressure_not_enough.png"
        SequentialAnimation on opacity {
            NumberAnimation { to: 1; duration: 400; easing.type: Easing.OutCubic }
            NumberAnimation { to: 0; duration: 400; easing.type: Easing.InCubic }
            loops: Animation.Infinite
            running: tire.visible
        }
    }
    Rectangle{
        id:tireRect
        anchors.bottom: parent.bottom
        anchors.left: tire.type!==0?tire.right:undefined
        anchors.right: tire.type===0?tire.left:undefined
        anchors.leftMargin: 5
        anchors.rightMargin: 5
        width: tireText.width+40
        height: 2.8
        color: Qt.rgba(0.8,0.8,0.8,0.8)
        antialiasing: true
    }
    CustomText{
        id:tireText
        text: img.status<0?"---":(String(tire.temp) +" °C"+"\n"+String(tire.pressure.toFixed(1)) +" Pa")
        font.pixelSize: 18
        anchors.horizontalCenter: tireRect.horizontalCenter
        anchors.bottom: tireRect.top
        anchors.bottomMargin: 10
        color: {
            switch (img.status){
            case 0:
                return Qt.rgba(0.7,0.7,0.7,1)
            case 1:
                return "yellow"
            case 2:
                return "red"
            default:
                return Qt.rgba(0.7,0.7,0.7,1)
            }
        }
    }
}
