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

SlideItem {
    id: radio
    width: parent.width
    height: parent.height
    enum RadioStatus {
        CLOSED = 0,
        FM = 1,
        AM = 2
    }
    property int status: Radio.CLOSED
    property string frequency: ""
    onStatusChanged: {
        ani.restart()
    }
    ParallelAnimation {
        id: ani
        NumberAnimation {
            target: rect
            property: "scale"
            easing.type: Easing.OutCubic
            duration: 400
            from: 0.8
            to: 1
        }
        NumberAnimation {
            target: rect
            property: "opacity"
            easing.type: Easing.OutCubic
            duration: 400
            from: 0
            to: 1
        }
    }
    Item {
        id: rect
        anchors.fill: parent
        readonly property real frequencyNum: tsFloat(radio.frequency)
        readonly property int num1: radio.status === Radio.FM ? (rect.frequencyNum / 100.0).toFixed(
                                                                    4) % 10 : (radio.status === Radio.AM ? (rect.frequencyNum / 1000.0).toFixed(4) % 10 : 0)
        readonly property int num2: radio.status === Radio.FM ? (rect.frequencyNum / 10.0).toFixed(
                                                                    3) % 10 : (radio.status === Radio.AM ? (rect.frequencyNum / 100.0).toFixed(3) % 10 : 0)
        readonly property int num3: radio.status === Radio.FM ? (rect.frequencyNum).toFixed(
                                                                    2) % 10 : (radio.status === Radio.AM ? (rect.frequencyNum / 10.0).toFixed(2) % 10 : 0)
        readonly property int num4: radio.status === Radio.FM ? (10.0 * rect.frequencyNum).toFixed(
                                                                    1) % 10 : (radio.status === Radio.AM ? (rect.frequencyNum).toFixed(1) % 10 : 0)
        function tsFloat(str) {
            var fnum = parseFloat(radio.frequency)
            if (fnum === NaN) {
                return 0
            }
            return fnum
        }
        Row {
            id: numRow
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -10
            height: 96
            anchors.verticalCenterOffset: -70
            spacing: 5
            ImageClip {
                id: a1
                width: 45
                height: 96
                source: ClusterManager.impSkinPath + "/radio/figure.png"
                index: rect.num1
                visible: index > 0
                antialiasing: true
            }
            ImageClip {
                id: a2
                width: 45
                height: 96
                source: ClusterManager.impSkinPath + "/radio/figure.png"
                index: rect.num2
                antialiasing: true
            }
            ImageClip {
                id: a3
                width: 45
                height: 96
                source: ClusterManager.impSkinPath + "/radio/figure.png"
                index: rect.num3
                antialiasing: true
            }
            Image {
                id: fmdot
                source: ClusterManager.impSkinPath + "/radio/figure_dot.png"
                visible: radio.status === Radio.FM
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                antialiasing: true
            }
            ImageClip {
                id: a4
                width: 45
                height: 96
                source: ClusterManager.impSkinPath + "/radio/figure.png"
                index: rect.num4
                antialiasing: true
            }
        }
        CustomText {
            font.pixelSize: 25
            text: radio.status === Radio.FM ? "MHz" : (radio.status === Radio.AM ? "KHz" : "")
            opacity: 1
            anchors.left: numRow.right
            anchors.leftMargin: 20
            anchors.verticalCenter: numRow.verticalCenter
            anchors.verticalCenterOffset: 10
        }
        CustomText {
            font.pixelSize: 45
            text: radio.status === Radio.FM ? "FM" : (radio.status === Radio.AM ? "AM" : "")
            anchors.left: numRow.right
            anchors.leftMargin: 20
            anchors.verticalCenter: numRow.verticalCenter
            anchors.verticalCenterOffset: -30
        }
        Image {
            id: imgLine
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 45
            anchors.horizontalCenterOffset: -10
            source: radio.status === Radio.FM ? ClusterManager.impSkinPath + "/radio/channel_fm.png" : (radio.status === Radio.AM ? ClusterManager.impSkinPath + "/radio/channel_am.png" : "")
            antialiasing: true
            Image {
                id: imgBar
                source: ClusterManager.impSkinPath + "/radio/channel_dot.png"
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -30
                antialiasing: true
                x: {
                    if (radio.status === Radio.FM) {
                        return (rect.frequencyNum - 88) / 20
                                * (imgLine.width - 38 * 2) - width / 2 + 38
                    } else if (radio.status === Radio.AM) {
                        return (rect.frequencyNum - 531) / 1098
                                * (imgLine.width - 38 * 2) - width / 2 + 38
                    } else {
                        return 0
                    }
                }
                Behavior on x {
                    NumberAnimation {
                        easing.type: Easing.OutCubic
                        duration: 200
                    }
                }
                SequentialAnimation on opacity {
                    NumberAnimation {
                        to: 1
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        to: 0.5
                        duration: 400
                        easing.type: Easing.InCubic
                    }
                    loops: Animation.Infinite
                    running: radio.status !== Radio.CLOSED && radio.visible
                }
            }
        }
    }
}
