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

Item {
    id: animation
    property bool doubleDial: false
    property bool isRunning: false
    //
    property real normalScale: 0.5
    property real miniScale: 1.2
    property real otherScale: 0.8
    property int normalDuration: 500
    property int miniDuration: 400
    property int otherDuration: 300
    property int maskDuration: 200
    Loader{
        id:animationVideo
        active: ClusterManager.hasAvAnimation
        asynchronous: false
        anchors.fill: parent
        source: "AnimationVideo.qml"
    }
    //    Timer{
    //        running: true
    //        interval: 5000
    //        repeat: true
    //        onTriggered: {
    //            if(doubleDial===true){
    //                playCloseAni()
    //                navi.stopNaviVideo()
    //            }else{
    //                playOpenAni()
    //                navi.playNaviVideo()
    //            }
    //        }
    //    }
    function reset() {
        if (iviEnabled && miniDashboard.enabled) {
            playOpenAni()
        } else {
            playCloseAni()
        }
    }
    function playOpenAni() {
        if (doubleDial === true) {
            return
        }
        doubleDial = true
        if(animationVideo.active===true){
            animationVideo.item.play(doubleDial)
        }
        openAni.stop()
        closeAni.stop()
        dashboardPartItem.scale = 1
        dashboardPartItem.opacity = 1
        backgroundImg.opacity = 1
        dashboard.scale = 1
        dashboard.opacity = 1
        miniDashboard.backImg.opacity = 0
        miniDashboard.scale = miniScale
        miniDashboard.opacity = 0
        miniDashboard.partItem.scale = otherScale
        miniDashboard.partItem.opacity = 0
        blackMask.opacity = 1
        openAni.start()
        isRunning = true
    }
    function playCloseAni() {
        if (doubleDial === false) {
            return
        }
        doubleDial = false
        if(animationVideo.active===true){
            animationVideo.item.play(doubleDial)
        }
        openAni.stop()
        closeAni.stop()
        dashboardPartItem.scale = otherScale
        dashboardPartItem.opacity = 0
        backgroundImg.opacity = 0
        dashboard.scale = normalScale
        dashboard.opacity = 0
        miniDashboard.backImg.opacity = 1
        miniDashboard.scale = 1
        miniDashboard.opacity = 1
        miniDashboard.partItem.scale = 1
        miniDashboard.partItem.opacity = 1
        blackMask.opacity = 0
        closeAni.start()
        isRunning = true
    }
    SequentialAnimation {
        id: openAni
        onRunningChanged: {
            if (running === false && blackMask.opacity === 0) {
                isRunning = false
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: dashboardPartItem
                property: "scale"
                easing.type: Easing.OutQuad
                from: 1
                to: otherScale
                duration: otherDuration
            }
            NumberAnimation {
                target: dashboardPartItem
                property: "opacity"
                easing.type: Easing.OutQuad
                from: 1
                to: 0
                duration: otherDuration
            }
        }
        NumberAnimation {
            target: backgroundImg
            property: "opacity"
            easing.type: Easing.OutQuad
            from: 1
            to: 0
            duration: maskDuration
        }
        ParallelAnimation {
            NumberAnimation {
                target: dashboard
                property: "scale"
                easing.type: Easing.OutQuad
                from: 1
                to: normalScale
                duration: normalDuration
            }
            NumberAnimation {
                target: dashboard
                property: "opacity"
                easing.type: Easing.OutQuad
                from: 1
                to: 0
                duration: normalDuration
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: miniDashboard
                property: "scale"
                easing.type: Easing.OutQuad
                from: miniScale
                to: 1
                duration: miniDuration
            }
            NumberAnimation {
                target: miniDashboard
                property: "opacity"
                easing.type: Easing.OutQuad
                from: 0
                to: 1
                duration: miniDuration
            }
        }
        PauseAnimation {
            duration: 0
        }
        ParallelAnimation {
            NumberAnimation {
                target: miniDashboard.backImg
                property: "opacity"
                easing.type: Easing.OutQuad
                from: 0
                to: 1
                duration: maskDuration
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: miniDashboard.partItem
                property: "scale"
                easing.type: Easing.OutQuad
                from: otherScale
                to: 1
                duration: otherDuration
            }
            NumberAnimation {
                target: miniDashboard.partItem
                property: "opacity"
                easing.type: Easing.OutQuad
                from: 0
                to: 1
                duration: otherDuration
            }
        }
        NumberAnimation {
            target: blackMask
            property: "opacity"
            easing.type: Easing.OutQuad
            from: 1
            to: 0
            duration: maskDuration
        }
    }
    //--------------------------
    SequentialAnimation {
        id: closeAni
        onRunningChanged: {
            if (running === false && dashboardPartItem.opacity === 1) {
                isRunning = false
            }
        }
        PauseAnimation {
            duration: 0
        }
        ParallelAnimation {
            NumberAnimation {
                target: blackMask
                property: "opacity"
                easing.type: Easing.OutQuad
                from: 0
                to: 1
                duration: maskDuration
            }
            ParallelAnimation {
                NumberAnimation {
                    target: miniDashboard.partItem
                    property: "scale"
                    easing.type: Easing.OutQuad
                    from: 1
                    to: otherScale
                    duration: otherDuration
                }
                NumberAnimation {
                    target: miniDashboard.partItem
                    property: "opacity"
                    easing.type: Easing.OutQuad
                    from: 1
                    to: 0
                    duration: otherDuration
                }
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: miniDashboard.backImg
                property: "opacity"
                easing.type: Easing.OutQuad
                from: 1
                to: 0
                duration: maskDuration
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: miniDashboard
                property: "scale"
                easing.type: Easing.OutQuad
                from: 1
                to: miniScale
                duration: miniDuration
            }
            NumberAnimation {
                target: miniDashboard
                property: "opacity"
                easing.type: Easing.OutQuad
                from: 1
                to: 0
                duration: miniDuration
            }
        }
        PauseAnimation {
            duration: 0
        }
        ParallelAnimation {
            NumberAnimation {
                target: dashboard
                property: "scale"
                easing.type: Easing.OutQuad
                from: normalScale
                to: 1
                duration: normalDuration
            }
            NumberAnimation {
                target: dashboard
                property: "opacity"
                easing.type: Easing.OutQuad
                from: 0
                to: 1
                duration: normalDuration
            }
        }
        NumberAnimation {
            target: backgroundImg
            property: "opacity"
            easing.type: Easing.OutQuad
            from: 0
            to: 1
            duration: maskDuration
        }
        ParallelAnimation {
            NumberAnimation {
                target: dashboardPartItem
                property: "scale"
                easing.type: Easing.OutQuad
                from: otherScale
                to: 1
                duration: otherDuration
            }
            NumberAnimation {
                target: dashboardPartItem
                property: "opacity"
                easing.type: Easing.OutQuad
                from: 0
                to: 1
                duration: otherDuration
            }
        }
    }
}
