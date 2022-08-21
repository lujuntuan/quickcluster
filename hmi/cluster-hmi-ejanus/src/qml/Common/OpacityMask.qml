﻿import QtQuick 2.15

Item {
    id: rootItem
    property var source
    property var maskSource
    property bool cached: false
    property bool invert: false
    SourceProxy {
        id: sourceProxy
        input: rootItem.source
    }
    SourceProxy {
        id: maskSourceProxy
        input: rootItem.maskSource
    }
    ShaderEffectSource {
        id: cacheItem
        anchors.fill: parent
        visible: rootItem.cached
        smooth: true
        sourceItem: shaderItem
        live: true
        hideSource: visible
    }
    ShaderEffect {
        id: shaderItem
        property var source: sourceProxy.output
        property var maskSource: maskSourceProxy.output
        property int invert: rootItem.invert ? 1 : 0
        anchors.fill: parent
        vertexShader: "qrc:/qml/Common/Shader/OpacityMask.vert"
        fragmentShader: "qrc:/qml/Common/Shader/OpacityMask.frag"
    }
}
