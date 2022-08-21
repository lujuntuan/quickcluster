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

Item {
    id: dashboard
    anchors.fill: parent
    property real speed: 0
    property real engine: 0
    property real fuel: 0
    property real water: 0
    property real avgFuel: 0
    property real maxFuel: 0
    property bool emergency: false
    property bool inited: false
    signal initFinished
    function playInitAni() {
        startAni.restart()
    }
    Binding {
        target: speedPanel
        when: dashboard.inited
        property: "value"
        value: dashboard.speed
    }
    Binding {
        target: enginePanel
        when: dashboard.inited
        property: "value"
        value: dashboard.engine
    }
    Binding {
        target: fuelPanel
        when: dashboard.inited
        property: "value"
        value: dashboard.fuel>dashboard.maxFuel?dashboard.maxFuel:dashboard.fuel
    }
    Binding {
        target: fuelPanel
        when: dashboard.inited
        property: "avgValue"
        value: dashboard.avgFuel
    }
    Binding {
        target: fuelPanel
        when: dashboard.inited
        property: "maxValue"
        value: dashboard.maxFuel
    }
    Binding {
        target: waterPanel
        when: dashboard.inited
        property: "value"
        value: dashboard.water
    }
    Item {
        width: 1920
        height: 642
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        SpeedPanel {
            id: speedPanel
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -30
        }
        EnginePanel {
            id: enginePanel
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -30
        }
        FuelPanel {
            id: fuelPanel
            anchors.left: speedPanel.left
            anchors.leftMargin: 85
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50
        }
        WaterPanel {
            id: waterPanel
            anchors.right: enginePanel.right
            anchors.rightMargin: 85
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50
        }
    }
    SequentialAnimation {
        id: startAni
        property int aniType: Easing.Linear
        property int aniDuration: 1000
        running: false
        loops: 1
        NumberAnimation {
            duration: 0
            target: fuelPanel
            property: "maxValue"
            to: 100
        }
        NumberAnimation {
            duration: 0
            target: fuelPanel
            property: "avgValue"
            to: 10
        }
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
                to: 8000
            }
            NumberAnimation {
                easing.type: startAni.aniType
                duration: startAni.aniDuration
                target: fuelPanel
                property: "value"
                to: 100
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
                target: fuelPanel
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
            dashboard.inited = true
            dashboard.initFinished()
        }
    }
}
