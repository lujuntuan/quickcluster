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
    id: clipImage
    property int index: 0
    property alias source: img.source
    width: img.width / 10
    height: img.height
    clip: true
    Image {
        id: img
        x: -clipImage.index * clipImage.width
        anchors.verticalCenter: parent.verticalCenter
        antialiasing: clipImage.antialiasing
    }
}
