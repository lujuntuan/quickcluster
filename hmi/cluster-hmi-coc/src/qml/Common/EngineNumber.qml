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
    id: root
    property real engineValue: 0
    property real value: 0
    property real cDistance: 0
    property alias source: customText.source
    antialiasing: true
    width: 80
    height: 80
    Component.onCompleted: {
        var angle = value / 10330 * 360 + 147
        var pangle = angle * (Math.PI / 180.0)
        x = cDistance * Math.cos(pangle) + parent.width / 2 - width / 2
        y = cDistance * Math.sin(pangle) + parent.height / 2 - height / 2
        rotation = angle - 270
    }
    onValueChanged: {
        fixed()
    }
    onEngineValueChanged: {
        fixed()
    }
    function fixed() {
        var pd = engineValue - value
        var pl = 0
        if (pd > 0) {
            pl = 1 - pd / 1000.0
            if (pl < 0) {
                pl = 0
            }
            if (pl > 1) {
                pl = 1
            }
            customText.opacity = 1
        } else {
            pl = 1 + pd / 1000.0
            if (pl < 0) {
                pl = 0
            }
            if (pl > 1) {
                pl = 1
            }
            customText.opacity = pl * 0.7 + 0.4
        }
        customText.scale = pl * 0.3 + 0.7
    }
    Image {
        id: customText
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        antialiasing: true
        smooth: true
        opacity: 0.4
        scale: 0.7
    }
}
