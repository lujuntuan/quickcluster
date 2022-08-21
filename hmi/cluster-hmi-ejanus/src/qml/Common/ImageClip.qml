import QtQuick 2.15

Item {
    id: clipImage
    property int index: 0
    property alias source: img.source
    width: img.width / 10
    height: img.height
    clip: true
    Image {
        id: img
        x: -clipImage.index * clipImage.width
        anchors.verticalCenter: parent.verticalCenter
        antialiasing: clipImage.antialiasing
    }
}
