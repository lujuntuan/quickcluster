import QtQuick 2.15
import QtAV 1.7 as QtAV

Item{
    id:filterVideo
    anchors.fill: parent
    visible: false
    property alias source: player.source
    signal playFinished()
    Component.onDestruction: {
        player.stop()
        player.source=""
    }
    function init(){
        player.play()
        player.pause()
    }
    function play(){
        player.play()
        filterVideo.visible=true
    }
    function stop(){
        player.stop()
        filterVideo.visible=false
    }
    QtAV.MediaPlayer{
        id:player
        autoPlay: false
        muted: true
        videoCodecPriority: "FFmpeg"
        onStatusChanged: {
            if(status===QtAV.MediaPlayer.EndOfMedia){
                filterVideo.visible=false
                playFinished()
            }
        }
    }
    QtAV.VideoOutput2{
        id:output
        anchors.fill: parent
        visible: false
        source: player
    }
    ShaderEffectSource {
        id:img
        anchors.fill: parent
        sourceItem: output
        visible: false
    }
    ShaderEffect {
        id:effect
        enabled: true
        property variant src: img
        anchors.fill: parent
        vertexShader:
"
        uniform highp mat4 qt_Matrix;
        attribute highp vec4 qt_Vertex;
        attribute highp vec2 qt_MultiTexCoord0;
        varying highp vec2 coord;
        void main() {
            coord = qt_MultiTexCoord0;
            gl_Position = qt_Matrix * qt_Vertex;
        }
"
        fragmentShader:
"
        varying lowp vec2 coord;
        uniform sampler2D src;
        uniform lowp float qt_Opacity;
        void main() {
            lowp vec4 tex = texture2D(src, coord);
            gl_FragColor = vec4(tex.r,tex.g,tex.b,0)*qt_Opacity;
        }
"
    }
}
