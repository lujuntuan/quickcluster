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

SlideItem {
    id: normal
    width: parent.width
    height: parent.height
    CustomText{
        text: "Automotive Multimedia"
        anchors.centerIn: parent
        font.pixelSize: 28
        font.bold: true
        color: skinMask.primaryColor
    }
}
