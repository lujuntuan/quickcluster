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

Item{
    id:drawLine
    property bool running: false
    property int times: 0
    property bool dymasic: false
    onRunningChanged: {
        lineCanvas.requestPaint()
        drawLine.clear()
    }
    function clear(){
        times=0
        ani.stop()
        dotImg.visible=false
        avgCanvas.lastPosX=0
        avgCanvas.lastPosY=drawLine.height/2
        avgCanvas.posX=avgCanvas.lastPosX
        avgCanvas.posY=avgCanvas.lastPosY
        avgCanvas.requestPaint()
        addTimer.restart()
    }
    function addValue(value){
        if(times<20){
            times++
        }else{
            clear()
            return
        }
        var x=drawLine.width/20*times
        var y=(1-value/45.0)*(drawLine.height-40)+20
        aniX.to=x
        aniY.to=y
        avgCanvas.lastPosX=avgCanvas.posX
        avgCanvas.lastPosY=avgCanvas.posY
        if(dymasic===true){
            ani.restart()
        }else{
            avgCanvas.posX=x
            avgCanvas.posY=y
        }
        dotImg.visible=true
    }
    function setValue(value){
        //none
    }
    function random(lower, upper) {
        return Math.floor(Math.random() * (upper - lower)) + lower
    }
    Timer{
        id:addTimer
        interval: 500
        running: drawLine.running
        repeat: true
        onTriggered: {
            var value=drawLine.random(0,6)
            drawLine.addValue(value*7.5)
        }
    }
    Rectangle{
        antialiasing: true
        anchors.top: parent.top
        anchors.right: parent.right
        width: parent.width
        height: 2.8
        color: Qt.rgba(0.8,0.8,0.8,0.8)
    }
    Rectangle{
        antialiasing: true
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: parent.width
        height: 2.8
        color: Qt.rgba(0.8,0.8,0.8,0.8)
    }
    Canvas{
        id:lineCanvas
        width: parent.width
        height: 5
        anchors.centerIn: parent
        antialiasing: true
        onPaint: {
            var context = getContext("2d")
            context.lineWidth=3
            context.strokeStyle=Qt.rgba(0.8,0.8,0.8,0.4)
            context.beginPath()
            context.clearRect(0,0,lineCanvas.width,lineCanvas.height)
            context.setLineDash([8, 4])
            context.moveTo(0, lineCanvas.height/2)
            context.lineTo(lineCanvas.width, lineCanvas.height/2)
            context.stroke()
        }
    }
    ParallelAnimation{
        id:ani
        NumberAnimation{
            id:aniX
            target: avgCanvas
            property: "posX"
            easing.type: Easing.OutQuad
            duration: 300
        }
        NumberAnimation{
            id:aniY
            target: avgCanvas
            property: "posY"
            easing.type: Easing.OutQuad
            duration: 300
        }
    }
    Canvas{
        id:avgCanvas
        anchors.fill: parent
        property real lastPosX: 0
        property real lastPosY: avgCanvas.height/2
        property real posX: lastPosX
        property real posY: lastPosY
        onPosXChanged: {
            avgCanvas.requestPaint()
        }
        renderTarget: Canvas.FramebufferObject
        renderStrategy :Canvas.Threaded
        antialiasing: true
        onPaint: {
            var context = getContext("2d")
            context.beginPath()
            context.imageSmoothingEnabled=true
            context.lineWidth=3
            context.strokeStyle=Qt.rgba(0.8,0.8,0.8,0.6)
            context.fillStyle=Qt.rgba(0.8,0.8,0.8,0.8)
            if(times===0){
                context.clearRect(0,0,avgCanvas.width,avgCanvas.height)
            }
            if(posX===aniX.to&&posY===aniY.to){
                context.arc(posX,posY,1.5,0,Math.PI*2.0,true)
                context.fill()
            }
            if(posX!==lastPosX||posY!==lastPosY){
                context.moveTo(lastPosX,lastPosY)
                context.lineTo(posX,posY)
                lastPosX=posX
                lastPosY=posY
            }
            context.stroke();
        }
    }
    Rectangle{
        id:dotImg
        x:avgCanvas.posX-width/2
        y:avgCanvas.posY-height/2
        visible: false
        antialiasing: true
        radius: 16
        width: 16
        height: 16
        color: "transparent"
        border.width: 2
        border.color: Qt.rgba(0.8,0.8,0.8,0.8)
        Rectangle{
            anchors.centerIn: parent
            width: 8
            height: 8
            radius: 8
            color: Qt.rgba(0.8,0.8,0.8,1)
        }
    }
}
