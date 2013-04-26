import QtQuick 1.1
import Sailfish.Silica 1.0

BackgroundItem {
    property alias icon: image.source

    width: parent.width
    height: image.height + theme.paddingMedium

    onClicked: parent._compass.closeMenu()

    Image {
        id: image

        anchors.centerIn: parent
    }
}
