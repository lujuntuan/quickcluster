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
    id: singleGauge
    anchors.fill: parent
    property real speed: 0
    property real engine: 0
    property real fuel: 0
    property real water: 0
    property real avgFuel: 0
    property real maxFuel: 0
    readonly property int aniDuration: 750
    property bool emergency: false
    property bool inited: false
    signal initFinished
    function playInitAni() {
        startAni.restart()
    }
    Binding {
        target: speedPanel
        when: singleGauge.inited
        property: "value"
        value: singleGauge.speed
    }
    Binding {
        target: enginePanel
        when: singleGauge.inited
        property: "value"
        value: singleGauge.engine
    }
    Binding {
        target: oilPanel
        when: singleGauge.inited
        property: "value"
        value: singleGauge.fuel
    }
    Binding {
        target: oilPanel
        when: singleGauge.inited
        property: "avg"
        value: singleGauge.avgFuel
    }
    Binding {
        target: oilPanel
        when: singleGauge.inited
        property: "max"
        value: singleGauge.maxFuel
    }
    Binding {
        target: waterPanel
        when: singleGauge.inited
        property: "value"
        value: singleGauge.water
    }
    Item {
        width: 803
        height: 703
        anchors.centerIn: parent
        OilPanel {
            id: oilPanel
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }
        WaterPanel {
            id: waterPanel
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }
        EnginePanel {
            id: enginePanel
            anchors.centerIn: parent
        }
        SpeedPanel {
            id: speedPanel
            anchors.centerIn: parent
        }
    }
    SequentialAnimation {
        id: startAni
        property int aniType: Easing.InOutSine
        property int aniDuration: 800
        running: false
        loops: 1
        PauseAnimation {
            duration: 500
        }
        ParallelAnimation {
            NumberAnimation {
                easing.type: startAni.aniType
                duration: startAni.aniDuration
                target: speedPanel
                property: "value"
                to: 240
            }
            NumberAnimation {
                easing.type: startAni.aniType
                duration: startAni.aniDuration
                target: enginePanel
                property: "value"
                to: 7000
            }
            NumberAnimation {
                easing.type: startAni.aniType
                duration: 0
                target: oilPanel
                property: "avg"
                to: 10
            }
            NumberAnimation {
                easing.type: startAni.aniType
                duration: 0
                target: oilPanel
                property: "max"
                to: 70
            }
            NumberAnimation {
                easing.type: startAni.aniType
                duration: startAni.aniDuration
                target: oilPanel
                property: "value"
                to: 70
            }
            NumberAnimation {
                easing.type: startAni.aniType
                duration: startAni.aniDuration
                target: waterPanel
                property: "value"
                to: 100
            }
        }
        PauseAnimation {
            duration: 150
        }
        ParallelAnimation {
            NumberAnimation {
                easing.type: startAni.aniType
                duration: startAni.aniDuration
                target: speedPanel
                property: "value"
                to: 0
            }
            NumberAnimation {
                easing.type: startAni.aniType
                duration: startAni.aniDuration
                target: enginePanel
                property: "value"
                to: 0
            }
            NumberAnimation {
                easing.type: startAni.aniType
                duration: startAni.aniDuration
                target: oilPanel
                property: "value"
                to: 0
            }
            NumberAnimation {
                easing.type: startAni.aniType
                duration: startAni.aniDuration
                target: waterPanel
                property: "value"
                to: 0
            }
        }
        PauseAnimation {
            duration: 50
        }
        onFinished: {
            singleGauge.inited = true
            singleGauge.initFinished()
        }
    }
}
