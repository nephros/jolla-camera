import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    property alias icon: image
    property alias background: backgroundCircle
    property real size: Theme.itemSizeSmall

    width: Theme.itemSizeExtraLarge
    height: Theme.itemSizeExtraLarge

    anchors.centerIn: parent

    Rectangle {
        id: backgroundCircle

        radius: size / 2
        width: size
        height: size

        anchors.centerIn: parent

        opacity: 0.6
        color: Theme.highlightDimmerColor
    }

    Image {
        id: image
        anchors.centerIn: parent
    }
}
