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

Item {
    id: dms
    enum DmsStatus {
        INVALID = 0,
        ATTENTION = 1,
        TIRED = 2
    }
    property int status: Dms.INVALID
    property int level: 0
    onStatusChanged: {
        rect.fixedDms()
    }
    onLevelChanged: {
        rect.fixedDms()
    }
    Image {
        id: rect
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 0
        opacity: 0
        visible: opacity > 0
        SequentialAnimation on scale {
            NumberAnimation {
                to: 1
                duration: 300
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                to: 1.06
                duration: 300
                easing.type: Easing.OutQuad
            }
            loops: Animation.Infinite
            running: rect.visible
        }
        Behavior on opacity {
            NumberAnimation {
                easing.type: Easing.OutCubic
                duration: 500
            }
        }
        source: ClusterManager.impSkinPath + "/msg/bg.png"
        function fixedDms() {
            if (dms.status === Dms.ATTENTION) {
                dmsText.text = qsTr("Please concentrate on the road.")
                if (level <= 1) {
                    icoImg.source = ClusterManager.impSkinPath
                            + "/msg/icon_tired.png"
                } else {
                    icoImg.source = ClusterManager.impSkinPath
                            + "/msg/icon_tired.png"
                }
                rect.opacity = 1
            } else if (dms.status === Dms.TIRED) {
                dmsText.text = qsTr(
                            "Fatigue driving is dangerous.\nPlease have a rest.")
                if (level <= 1) {
                    icoImg.source = ClusterManager.impSkinPath
                            + "/msg/icon_tired.png"
                } else {
                    icoImg.source = ClusterManager.impSkinPath + "/msg/icon_tired.png"
                }
                rect.opacity = 1
            } else {
                dmsText.text = ""
                icoImg.source = ""
                rect.opacity = 0
            }
        }
        Item {
            width: 150
            height: parent.height
            Image {
                id: icoImg
                source: ""
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 5
                scale: 0.8
            }
        }
        CustomText {
            id: dmsText
            anchors.fill: parent
            anchors.margins: 10
            anchors.leftMargin: 150
            text: ""
            color: "white"
            font.pixelSize: 30
            font.bold: true
        }
    }
}
