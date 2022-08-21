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
    id: dotsItem
    property int count: 3
    property int radius: 5
    property int spacing: 5
    property int interval: 250
    property color color: Qt.rgba(0.8, 0.8, 0.8, 1)
    property bool reverse: false
    property bool still: false
    width: row.width
    height: row.height
    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: dotsItem.spacing
        layoutDirection: dotsItem.reverse ? Qt.RightToLeft : Qt.LeftToRight
        Repeater {
            model: dotsItem.count
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: dotsItem.radius
                height: dotsItem.radius
                radius: dotsItem.radius
                color: (index < timer.index
                        || dotsItem.still) ? dotsItem.color : "transparent"
            }
        }
    }
    Timer {
        id: timer
        running: dotsItem.visible && dotsItem.count > 1 && !dotsItem.still
        repeat: true
        interval: dotsItem.interval
        property int index: 0
        onTriggered: {
            if (index < count) {
                index++
            } else {
                index = 0
            }
        }
    }
}
