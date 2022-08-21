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
    //            }else{
    //                playOpenAni()
    //            }
    //        }
    //    }
    function reset() {
        if (iviEnabled && doubleGauge.enabled) {
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
        singleGaugePartItem.scale = 1
        singleGaugePartItem.opacity = 1
        backgroundImg.opacity = 1
        singleGauge.scale = 1
        singleGauge.opacity = 1
        doubleGauge.backImg.opacity = 0
        doubleGauge.scale = 0.9
        doubleGauge.opacity = 0
        doubleGauge.partItem.scale = 0.9
        doubleGauge.partItem.opacity = 0
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
        singleGaugePartItem.scale = 0.9
        singleGaugePartItem.opacity = 0
        backgroundImg.opacity = 0
        singleGauge.scale = 1.2
        singleGauge.opacity = 0
        doubleGauge.backImg.opacity = 1
        doubleGauge.scale = 1
        doubleGauge.opacity = 1
        doubleGauge.partItem.scale = 1
        doubleGauge.partItem.opacity = 1
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
                target: singleGaugePartItem
                property: "scale"
                easing.type: Easing.OutQuad
                from: 1
                to: 0.9
                duration: 200
            }
            NumberAnimation {
                target: singleGaugePartItem
                property: "opacity"
                easing.type: Easing.OutQuad
                from: 1
                to: 0
                duration: 200
            }
            NumberAnimation {
                target: telltales
                property: "opacity"
                easing.type: Easing.OutQuad
                from: 1
                to: 0
                duration: 200
            }
        }
        NumberAnimation {
            target: backgroundImg
            property: "opacity"
            easing.type: Easing.OutQuad
            from: 1
            to: 0
            duration: 200
        }
        ParallelAnimation {
            NumberAnimation {
                target: singleGauge
                property: "scale"
                easing.type: Easing.OutQuad
                from: 1
                to: 1.2
                duration: 200
            }
            NumberAnimation {
                target: singleGauge
                property: "opacity"
                easing.type: Easing.OutQuad
                from: 1
                to: 0
                duration: 200
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: doubleGauge
                property: "scale"
                easing.type: Easing.OutQuad
                from: 0.9
                to: 1
                duration: 200
            }
            NumberAnimation {
                target: doubleGauge
                property: "opacity"
                easing.type: Easing.OutQuad
                from: 0
                to: 1
                duration: 200
            }
        }
        PauseAnimation {
            duration: 0
        }
        ParallelAnimation {
            NumberAnimation {
                target: doubleGauge.backImg
                property: "opacity"
                easing.type: Easing.OutQuad
                from: 0
                to: 1
                duration: 200
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: doubleGauge.partItem
                property: "scale"
                easing.type: Easing.OutQuad
                from: 0.9
                to: 1
                duration: 200
            }
            NumberAnimation {
                target: doubleGauge.partItem
                property: "opacity"
                easing.type: Easing.OutQuad
                from: 0
                to: 1
                duration: 200
            }
        }
        NumberAnimation {
            target: blackMask
            property: "opacity"
            easing.type: Easing.OutQuad
            from: 1
            to: 0
            duration: 200
        }
    }
    //--------------------------
    SequentialAnimation {
        id: closeAni
        onRunningChanged: {
            if (running === false && singleGaugePartItem.opacity === 1) {
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
                duration: 200
            }
            ParallelAnimation {
                NumberAnimation {
                    target: doubleGauge.partItem
                    property: "scale"
                    easing.type: Easing.OutQuad
                    from: 1
                    to: 0.9
                    duration: 200
                }
                NumberAnimation {
                    target: doubleGauge.partItem
                    property: "opacity"
                    easing.type: Easing.OutQuad
                    from: 1
                    to: 0
                    duration: 200
                }
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: doubleGauge.backImg
                property: "opacity"
                easing.type: Easing.OutQuad
                from: 1
                to: 0
                duration: 200
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: doubleGauge
                property: "scale"
                easing.type: Easing.OutQuad
                from: 1
                to: 0.9
                duration: 200
            }
            NumberAnimation {
                target: doubleGauge
                property: "opacity"
                easing.type: Easing.OutQuad
                from: 1
                to: 0
                duration: 200
            }
        }
        PauseAnimation {
            duration: 0
        }
        ParallelAnimation {
            NumberAnimation {
                target: singleGauge
                property: "scale"
                easing.type: Easing.OutQuad
                from: 1.2
                to: 1
                duration: 200
            }
            NumberAnimation {
                target: singleGauge
                property: "opacity"
                easing.type: Easing.OutQuad
                from: 0
                to: 1
                duration: 200
            }
        }
        NumberAnimation {
            target: backgroundImg
            property: "opacity"
            easing.type: Easing.OutQuad
            from: 0
            to: 1
            duration: 200
        }
        ParallelAnimation {
            NumberAnimation {
                target: singleGaugePartItem
                property: "scale"
                easing.type: Easing.OutQuad
                from: 0.9
                to: 1
                duration: 200
            }
            NumberAnimation {
                target: singleGaugePartItem
                property: "opacity"
                easing.type: Easing.OutQuad
                from: 0
                to: 1
                duration: 200
            }
            NumberAnimation {
                target: telltales
                property: "opacity"
                easing.type: Easing.OutQuad
                from: 0
                to: 1
                duration: 200
            }
        }
    }
}
