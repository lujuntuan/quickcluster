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

Item{
    id:navi
    Loader{
        id:video
        anchors.fill: parent
        active: ClusterManager.hasAvNavi
        asynchronous: false
        source: "FullVideo.qml"
    }
    function reset(){
        if (iviEnabled && miniDashboard.enabled) {
            playNaviVideo()
        } else {
            stopNaviVideo()
        }
    }
    function playNaviVideo(){
        if(video.active===true){
            video.item.play()
        }
    }
    function stopNaviVideo(){
        if(video.active===true){
            video.item.stop()
        }
    }
}
