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

Rectangle {
    id: skinMask
    property string skin: "unknown"
    anchors.fill: parent
    opacity: 0
    visible: opacity > 0
    color: "black"
    signal changed()
    onOpacityChanged: {
        if (skinMask.opacity === 0 || skinMask.opacity === 1) {
            timer.restart()
        }
    }
    function init(skin) {
        skinMask.skin=skin
    }
    function setSkin(skin) {
        if(skinMask.skin!==skin){
            skinMask.skin=skin
            ani.from = 0
            ani.to = 1
            ani.restart()
        }
    }
    Timer {
        id: timer
        repeat: false
        interval: 200
        running: false
        onTriggered: {
            if (skinMask.opacity === 1) {
                skinMask.changed()
                ani.from = 1
                ani.to = 0
                ani.restart()
            }
        }
    }
    Rectangle{
        width: 500
        height: 100
        radius: 10
        color: "white"
        anchors.centerIn: parent
        Text {
            text: qsTr("Please wait ...")
            font.pixelSize: 50
            color: "black"
            renderType: Text.QtRendering
            verticalAlignment: Text.AlignVCenter
            anchors.centerIn: parent
        }
    }
    NumberAnimation {
        id: ani
        target: skinMask
        property: "opacity"
        duration: 400
        from: 0
        to: 1
    }
}
