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
    id: animationVideo
    FilterVideo{
        id:startVideo
        source: "qrc:/"+ClusterManager.skin+"/video/start.mp4"
    }
    FilterVideo{
        id:stopVideo
        source: "qrc:/"+ClusterManager.skin+"/video/stop.mp4"
    }
    Component.onCompleted: {
        startVideo.init()
        stopVideo.init()
    }
    function play(doubleDial){
        if(doubleDial){
            startVideo.play()
            stopVideo.stop()
        }else{
            startVideo.stop()
            stopVideo.play()
        }
    }
}
