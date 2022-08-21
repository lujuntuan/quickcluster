import QtQuick 2.15

Item {
    id: scrollText
    clip: true
    property alias text: textRect.text
    property alias font: textRect.font
    property alias color: textRect.color
    property bool textToCenter: true
    onVisibleChanged: {
        textRect.fixedRunning()
    }
    Text {
        id: textRect
        font.pixelSize: 16
        color: Qt.rgba(0.8, 0.8, 0.8, 1)
        renderType: Text.QtRendering
        verticalAlignment: Text.AlignVCenter
        property int offset: scrollText.width - textRect.width
        onOffsetChanged: {
            textRect.fixedRunning()
        }
        x: 0
        anchors.verticalCenter: parent.verticalCenter
        width: textRect.contentWidth
        height: textRect.contentHeight
        text: ""
        clip: true
        function fixedRunning() {
            ani.stop()
            if (scrollText.visible && textRect.offset < 0) {
                ani.poffset = textRect.offset
                ani.pduration = -textRect.offset * 50
                textRect.x = 0
                ani.start()
            } else {
                ani.poffset = 0
                ani.pduration = 0
                if (scrollText.textToCenter) {
                    textRect.x = textRect.offset / 2
                } else {
                    textRect.x = 0
                }
            }
        }
        SequentialAnimation {
            id: ani
            loops: Animation.Infinite
            running: false
            property int poffset: 0
            property int pduration: 0
            PauseAnimation {
                duration: 1000
            }
            NumberAnimation {
                target: textRect
                property: "x"
                easing.type: Easing.OutQuad
                from: 0
                to: ani.poffset
                duration: ani.pduration
            }
            PauseAnimation {
                duration: 1000
            }
            NumberAnimation {
                target: textRect
                property: "x"
                easing.type: Easing.OutQuad
                from: ani.poffset
                to: 0
                duration: ani.pduration
            }
        }
    }
}
