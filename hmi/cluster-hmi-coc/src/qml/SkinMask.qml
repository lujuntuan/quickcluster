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
    property color primaryColor: "green"
    property color minorColor: "yellow"
    property color decorateColor: "blue"
    property color foregroundColor: "white"
    property color backgroundColor: "black"
    anchors.fill: parent
    opacity: 0
    visible: opacity > 0
    color: skinMask.backgroundColor
    signal changed()
    onOpacityChanged: {
        if (skinMask.opacity === 0 || skinMask.opacity === 1) {
            timer.restart()
        }
    }
    function init(skin) {
        skinMask.skin=skin
        adjustColor()
    }
    function setSkin(skin) {
        if(skinMask.skin!==skin){
            skinMask.skin=skin
            ani.from = 0
            ani.to = 1
            ani.restart()
        }
    }
    function adjustColor() {
        switch(skinMask.skin){
        case "blue":
            primaryColor=Qt.rgba(0.8, 0.8, 0.9, 0.9)
            minorColor=Qt.rgba(0.9, 0.9, 1.0, 0.95)
            decorateColor=Qt.rgba(0.07, 0.26, 0.47, 1.0)
            foregroundColor=Qt.rgba(0.9, 0.9, 1.0, 1.0)
            backgroundColor=Qt.rgba(0.03, 0.1, 0.25, 1.0)
            break
        case "dark":
            primaryColor=Qt.rgba(0.9, 0.8, 0.8, 0.9)
            minorColor=Qt.rgba(1.0, 0.9, 0.9, 0.95)
            decorateColor=Qt.rgba(0.2, 0.04, 0.08, 1.0)
            foregroundColor=Qt.rgba(1.0, 0.9, 0.9, 1.0)
            backgroundColor=Qt.rgba(0.1, 0.08, 0.08, 1.0)
            break
        case "light":
            primaryColor=Qt.rgba(0.1, 0.1, 0.4, 0.9)
            minorColor=Qt.rgba(0.1, 0.1, 0.3, 0.95)
            decorateColor=Qt.rgba(0.06, 0.13, 0.33, 1.0)
            foregroundColor=Qt.rgba(0.2, 0.25, 0.4, 1.0)
            backgroundColor=Qt.rgba(0.65, 0.7, 0.85, 1.0)
            break
        default:
            break
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
                adjustColor()
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
        color: skinMask.foregroundColor
        anchors.centerIn: parent
        Text {
            text: qsTr("Please wait ...")
            font.pixelSize: 50
            color: backgroundColor
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
