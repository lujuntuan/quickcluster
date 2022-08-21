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
import "../Common"

Item {
    id: gearRect
    width: rect.width
    height: rect.height
    enum Gear {
        GEAR_P = 0,
        GEAR_R = 1,
        GEAR_N = 2,
        GEAR_D = 3
    }
    property int gear: 0
    ParallelAnimation {
        id: ani
        NumberAnimation {
            id: ani1
            target: rect
            property: "opacity"
            duration: 500
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            id: ani2
            target: rect
            property: "y"
            duration: 500
            easing.type: Easing.OutCubic
        }
    }
    function show() {
        ani1.from = 0
        ani1.to = 1
        ani2.from = rect.height
        ani2.to = 0
        ani.restart()
    }
    function hide() {
        ani1.from = 1
        ani1.to = 0
        ani2.from = 0
        ani2.to = rect.height
        ani.restart()
    }
    Item {
        id:rect
        width: 300
        height: 50
        opacity: 0
        y: rect.height
        Row {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 5
            spacing: 25
            Repeater {
                model: 4
                CustomText{
                    id:grearText
                    property bool isCurrent: gearRect.gear === index
                    opacity: isCurrent?1:0.25
                    font.pixelSize: 55
                    font.bold: isCurrent
                    scale: 0.85
                    color: skinMask.primaryColor
                    text: {
                        switch (index) {
                        case GearRect.GEAR_P:
                            return "P"
                        case GearRect.GEAR_R:
                            return "R"
                        case GearRect.GEAR_N:
                            return "N"
                        case GearRect.GEAR_D:
                            return "D"
                        }
                    }
                    onIsCurrentChanged: {
                        if (isCurrent === true) {
                            gearAni.restart()
                        } else {
                            gearAni.stop()
                            grearText.scale = 0.85
                        }
                    }
                    NumberAnimation {
                        id: gearAni
                        target: grearText
                        property: "scale"
                        easing.type: Easing.OutCubic
                        duration: 200
                        from: 0.85
                        to: 1
                    }
                }
            }
        }
    }
}
