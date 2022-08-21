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
    id: showItem
    property bool show: false
    enum Direct {
        LEFT = 0,
        RIGHT = 1
    }
    property int direct: SlideItem.LEFT
    visible: false
    opacity: 0
    width: parent.width
    height: parent.height
    x: 0
    y: 0
    onShowChanged: {
        showItem.visible = true
        showAni.stop()
        hideAni.stop()
        if (show === true) {
            showAni.start()
        } else {
            hideAni.start()
        }
    }
    ParallelAnimation {
        id: showAni
        NumberAnimation {
            target: showItem
            property: "x"
            easing.type: Easing.OutCubic
            from: direct === SlideItem.RIGHT ? -showItem.width / 2 : showItem.width / 2
            to: 0
            duration: 500
        }
        NumberAnimation {
            target: showItem
            property: "opacity"
            easing.type: Easing.OutCubic
            from: 0
            to: 1
            duration: 500
        }
        onRunningChanged: {
            if (running === true) {
                showItem.visible = true
            } else {
                showItem.visible = true
            }
        }
    }
    ParallelAnimation {
        id: hideAni
        NumberAnimation {
            target: showItem
            property: "x"
            easing.type: Easing.OutCubic
            from: 0
            to: direct === SlideItem.RIGHT ? showItem.width / 2 : -showItem.width / 2
            duration: 500
        }
        NumberAnimation {
            target: showItem
            property: "opacity"
            easing.type: Easing.OutCubic
            from: 1
            to: 0
            duration: 500
        }
        onRunningChanged: {
            if (running === true) {
                showItem.visible = true
            } else {
                showItem.visible = false
            }
        }
    }
}
