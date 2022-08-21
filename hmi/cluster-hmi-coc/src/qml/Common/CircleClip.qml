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
    property alias centerPoint: effect.centerPoint
    property alias startAngle: effect.startAngle
    property alias stopAngle: effect.stopAngle
    property alias smoothRadius: effect.smoothRadius
    property alias source: targetImage.source
    width: targetImage.sourceSize.width
    height: targetImage.sourceSize.height
    function getBezierCubic(p1, p2, t) {
        var temp = 1.0 - t
        var target = 3.0 * p1 * t * temp * temp + 3.0 * p2 * t * t * temp + 1 * t * t * t
        return target
    }
    Image {
        id: targetImage
        anchors.fill: parent
        visible: false
    }
    ShaderEffect {
        id: effect
        width: targetImage.width
        height: targetImage.height
        blending: true
        visible: true
        cullMode: ShaderEffect.BackFaceCulling
        property point centerPoint: Qt.point(width / 2, height / 2)
        property real startAngle: 0
        property real stopAngle: 360
        property real smoothRadius: 0.2
        property var image: targetImage
        vertexShader: "qrc:/qml/Common/Shader/CircleClip.vert"
        fragmentShader: "qrc:/qml/Common/Shader/CircleClip.frag"
    }
}
