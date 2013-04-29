import QtQuick 1.1
import Sailfish.Silica 1.0

BackgroundItem {
    property alias icon: image.source

    width: parent.width
    height: image.height + theme.paddingLarge

    onClicked: parent._compass.closeMenu()

    Image {
        id: image

        // temporary while some images do not fit.
        width: 24; height: 24; fillMode: Image.PreserveAspectFit
        anchors.centerIn: parent
    }
}
