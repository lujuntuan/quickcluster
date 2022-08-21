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
import QtAV 1.7 as QtAV

Item{
    id:fillVideo
    anchors.fill: parent
    property alias source: player.source
    signal playFinished()
    Component.onDestruction: {
        player.stop()
        player.source=""
    }
    function play(){
        player.play()
    }
    function stop(){
        player.stop()
    }
    QtAV.MediaPlayer{
        id:player
        autoPlay: true
        muted: true
        source: "qrc:/qml/Navi/navi.sdp"
        useWallclockAsTimestamps: true
        bufferSize: 1
        videoCodecPriority: "FFmpeg"
        avFormatOptions: {
            "protocol_whitelist":"file,udp,rtp"
        }
        onStatusChanged: {
            if(status===QtAV.MediaPlayer.EndOfMedia){
                playFinished()
            }
        }
    }
    QtAV.VideoOutput2{
        id:output
        anchors.fill: parent
        visible: true
        source: player
    }
}
