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
    id: doublePart
    //oil
    Image {
        x: parent.width / 2 - width / 2 - 355 - 70
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 75
        source: doubleGauge.visible ? (doubleGauge.fuel <= 15.0 ? ClusterManager.impSkinPath + "/doubleGuage/icon_oil_deficiency.png" : ClusterManager.impSkinPath + "/doubleGuage/icon_oil_normal.png") : ""
    }
    CustomText {
        x: parent.width / 2 - width / 2 - 355
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 75
        property real lessKm: avgFuel > 0 ? fuel / avgFuel * 100 : 0
        text: doubleGauge.visible ? String(lessKm.toFixed(0)) : "0"
        width: 100
        height: 34
        font.pixelSize: 30
        font.bold: false
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    Image {
        x: parent.width / 2 - width / 2 - 355 + 70
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 83
        source: ClusterManager.impSkinPath + "/doubleGuage/km.png"
    }
    CustomText {
        x: parent.width / 2 - width / 2 - 355 - 210
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 35
        text: "E"
        width: 100
        height: 34
        font.pixelSize: 30
        font.bold: false
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    CustomText {
        x: parent.width / 2 - width / 2 - 355 + 210
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 35
        text: "F"
        width: 100
        height: 34
        font.pixelSize: 30
        font.bold: false
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    Image {
        x: parent.width / 2 - width / 2 - 355
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        source: ClusterManager.impSkinPath + "/doubleGuage/progress_bar_bg.png"
    }
    Row {
        id: oil_item
        visible: false
        Image {
            source: doubleGauge.visible ? (doubleGauge.fuel <= 5 ? ClusterManager.impSkinPath + "/doubleGuage/progress_bar_red_left.png" : ClusterManager.impSkinPath + "/doubleGuage/progress_bar_left.png") : ""
        }
        Repeater {
            model: 6
            Image {
                source: doubleGauge.visible ? ClusterManager.impSkinPath
                                              + "/doubleGuage/progress_bar_mid.png" : ""
            }
        }
        Image {
            source: doubleGauge.visible ? ClusterManager.impSkinPath
                                          + "/doubleGuage/progress_bar_right.png" : ""
        }
    }
    ShaderEffectSource {
        id: oil_img
        sourceItem: oil_item
        visible: false
    }
    ShaderEffect {
        id: oil_effect
        enabled: doubleGauge.visible
        property variant src: oil_img
        property real oilbl: doubleGauge.fuel / doubleGauge.maxFuel
        width: oil_item.width
        height: oil_item.height
        x: parent.width / 2 - width / 2 - 355
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        vertexShader: "
uniform highp mat4 qt_Matrix;
attribute highp vec4 qt_Vertex;
attribute highp vec2 qt_MultiTexCoord0;
varying highp vec2 coord;
void main() {
coord = qt_MultiTexCoord0;
gl_Position = qt_Matrix * qt_Vertex;
}"
        fragmentShader: "
varying highp vec2 coord;
uniform sampler2D src;
uniform lowp float oilbl;
uniform lowp float qt_Opacity;
void main() {
lowp vec4 tex = texture2D(src, coord);
if(coord.x<oilbl){
gl_FragColor = tex*qt_Opacity;
}else{
gl_FragColor = vec4(0,0,0,0);
}
}"
        Image {
            x: oil_effect.oilbl * oil_effect.width
            source: doubleGauge.visible ? (doubleGauge.fuel <= 5 ? ClusterManager.impSkinPath + "/doubleGuage/progress_bar_red_mid_2.png" : ClusterManager.impSkinPath + "/doubleGuage/progress_bar_mid_2.png") : ""
            visible: oil_effect.oilbl > 1 / 12.0 && oil_effect.oilbl < 11 / 12.0
        }
    }
    //water
    Image {
        x: parent.width / 2 - width / 2 + 355 - 70
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 75
        source: doubleGauge.visible ? (doubleGauge.water <= 10
                                       || doubleGauge.water >= 90.0 ? ClusterManager.impSkinPath + "/doubleGuage/icon_water_fault.png" : ClusterManager.impSkinPath + "/doubleGuage/icon_water_normal.png") : ""
    }
    CustomText {
        x: parent.width / 2 - width / 2 + 355
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 75
        text: doubleGauge.visible ? String(doubleGauge.water.toFixed(0)) : "0"
        width: 100
        height: 34
        font.pixelSize: 30
        font.bold: false
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    Image {
        x: parent.width / 2 - width / 2 + 355 + 70
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 83
        source: ClusterManager.impSkinPath + "/doubleGuage/Celsius.png"
    }
    CustomText {
        x: parent.width / 2 - width / 2 + 355 - 210
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 35
        text: "C"
        width: 100
        height: 34
        font.pixelSize: 30
        font.bold: false
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    CustomText {
        x: parent.width / 2 - width / 2 + 355 + 210
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 35
        text: "H"
        width: 100
        height: 34
        font.pixelSize: 30
        font.bold: false
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    Image {
        x: parent.width / 2 - width / 2 + 355
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        source: ClusterManager.impSkinPath + "/doubleGuage/progress_bar_bg.png"
    }
    Row {
        id: water_item
        visible: false
        Image {
            source: doubleGauge.visible ? (doubleGauge.water <= 10
                                           || doubleGauge.water >= 90 ? ClusterManager.impSkinPath + "/doubleGuage/progress_bar_red_left.png" : ClusterManager.impSkinPath + "/doubleGuage/progress_bar_left.png") : ""
        }
        Repeater {
            model: 6
            Image {
                source: doubleGauge.visible ? (doubleGauge.water <= 10
                                               || doubleGauge.water >= 90 ? ClusterManager.impSkinPath + "/doubleGuage/progress_bar_red_mid.png" : ClusterManager.impSkinPath + "/doubleGuage/progress_bar_mid.png") : ""
            }
        }
        Image {
            source: doubleGauge.visible ? (doubleGauge.water <= 10
                                           || doubleGauge.water >= 90 ? ClusterManager.impSkinPath + "/doubleGuage/progress_bar_red_right.png" : ClusterManager.impSkinPath + "/doubleGuage/progress_bar_right.png") : ""
        }
    }
    ShaderEffectSource {
        id: water_img
        sourceItem: water_item
        visible: false
    }
    ShaderEffect {
        id: water_effect
        enabled: doubleGauge.visible
        property variant src: water_img
        property real waterbl: doubleGauge.water / 100.0
        width: water_item.width
        height: water_item.height
        x: parent.width / 2 - width / 2 + 355
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        vertexShader: "
uniform highp mat4 qt_Matrix;
attribute highp vec4 qt_Vertex;
attribute highp vec2 qt_MultiTexCoord0;
varying highp vec2 coord;
void main() {
coord = qt_MultiTexCoord0;
gl_Position = qt_Matrix * qt_Vertex;
}"
        fragmentShader: "
varying highp vec2 coord;
uniform sampler2D src;
uniform lowp float waterbl;
uniform lowp float qt_Opacity;
void main() {
lowp vec4 tex = texture2D(src, coord);
if(coord.x<waterbl){
gl_FragColor = tex*qt_Opacity;
}else{
gl_FragColor = vec4(0,0,0,0);
}
}"
        Image {
            x: water_effect.waterbl * water_effect.width
            source: doubleGauge.visible ? (doubleGauge.water <= 10
                                           || doubleGauge.water >= 90 ? ClusterManager.impSkinPath + "/doubleGuage/progress_bar_red_mid_2.png" : ClusterManager.impSkinPath + "/doubleGuage/progress_bar_mid_2.png") : ""
            visible: water_effect.waterbl > 1 / 12.0
                     && water_effect.waterbl < 11 / 12.0
        }
    }
    //dangwei
    Image {
        source: ClusterManager.impSkinPath + "/doubleGuage/Gear_position_bg.png"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
    }
    CustomText {
        id: gearText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        text: {
            switch (gear) {
            case DoubleGauge.GEAR_P:
                return "P"
            case DoubleGauge.GEAR_R:
                return "R"
            case DoubleGauge.GEAR_N:
                return "N"
            case DoubleGauge.GEAR_D:
                return "D"
            }
        }
        width: 100
        height: 100
        font.pixelSize: 50
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        SequentialAnimation {
            id: gearAni
            NumberAnimation {
                target: gearText
                property: "scale"
                duration: 250
                easing.type: Easing.OutQuad
                from: 1
                to: 1.2
            }
            NumberAnimation {
                target: gearText
                property: "scale"
                duration: 250
                easing.type: Easing.InQuad
                from: 1.2
                to: 1
            }
        }
        onTextChanged: {
            if (doubleGauge.visible) {
                gearAni.restart()
            }
        }
    }
    //title
    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 14
        width: 150
        height: 30
        CustomText {
            id: timeText
            anchors.centerIn: parent
            text: doubleGauge.date.getFullYear(
                      ) < 2000 ? "---" : doubleGauge.date.toLocaleTimeString(
                                     Qt.locale("en_US"), "hh:mm ap")
            font.pixelSize: 32
            font.bold: false
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
    CustomText {
        x: parent.width / 2 - width / 2 - 200
        anchors.top: parent.top
        anchors.topMargin: 14
        width: 150
        height: 30
        text: (doubleGauge.temp > 100
               || doubleGauge.temp < -100) ? "--- °C" : (doubleGauge.temp.toFixed(
                                                             0) + " °C")
        font.pixelSize: 32
        font.bold: false
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    CustomText {
        x: parent.width / 2 - width / 2 + 200
        anchors.top: parent.top
        anchors.topMargin: 14
        width: 150
        height: 30
        text: doubleGauge.total < 0 ? "--- km" : String(
                                          doubleGauge.total.toFixed(1)) + " km"
        font.pixelSize: 32
        font.bold: false
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    Image {
        x: parent.width / 2 - width / 2 - 350
        anchors.top: parent.top
        anchors.topMargin: 7
        source: ClusterManager.impSkinPath + "/doubleGuage/icon_left_signal.png"
        opacity: doubleGauge.leftSignal === true ? 1 : 0
        visible: opacity > 0
        Behavior on opacity {
            NumberAnimation {
                easing.type: Easing.OutCubic
                duration: 200
            }
        }
    }
    Image {
        x: parent.width / 2 - width / 2 + 350
        anchors.top: parent.top
        anchors.topMargin: 7
        source: ClusterManager.impSkinPath + "/doubleGuage/icon_right_signal.png"
        opacity: doubleGauge.rightSignal === true ? 1 : 0
        visible: opacity > 0
        Behavior on opacity {
            NumberAnimation {
                easing.type: Easing.OutCubic
                duration: 200
            }
        }
    }
}
