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
    id: telltalesImage
    property string name: ""
    property var nameList: [name]
    property bool aniEnabled: true
    width: 50
    height: 50
    Image {
        anchors.centerIn: parent
        readonly property int targetIndex: {
            if(!inited){
                return 1
            }
            if (telltalesMap[telltalesImage.name] === undefined || telltalesMap[telltalesImage.name] === null) {
                return 0
            }
            return telltalesMap[telltalesImage.name]
        }
        readonly property string targetName: {
            if (targetIndex <= 0) {
                return telltalesImage.nameList[0]
            }
            if (targetIndex - 1 < telltalesImage.nameList.length) {
                return telltalesImage.nameList[targetIndex - 1]
            }
            return ""
        }
        fillMode: Image.PreserveAspectFit
        source: targetName === "" ? "" : ClusterManager.impSkinPath + "/"+iconPath+"/" + targetName + ".png"
        visible: opacity > 0
        Behavior on opacity {
            enabled: telltalesImage.aniEnabled
            NumberAnimation {
                easing.type: Easing.OutCubic
                duration: 100
            }
        }
        opacity: targetIndex === 0 ? 0 : 1
    }
}
