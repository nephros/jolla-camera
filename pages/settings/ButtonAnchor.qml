import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

MouseArea {
    property int index

    anchors.margins: Theme.paddingLarge + Theme.paddingMedium

    width: Theme.itemSizeMedium
    height: Theme.itemSizeMedium

    z: 1

    parent: overlay._captureButtonLocation == index
                ? (anchorContainer.visible ? settingsOverlay : container)
                : anchorContainer

    enabled: !anchorContainer.visible || overlay._captureButtonLocation != index

    onClicked: {
        if (index >= 0) {
            if (overlay.isPortrait) {
                Settings.global.portraitCaptureButtonLocation = index
            } else {
                Settings.global.landscapeCaptureButtonLocation = index
            }
        }
    }

    Rectangle {
        radius: Theme.itemSizeSmall / 2
        width: Theme.itemSizeSmall
        height: Theme.itemSizeSmall

        anchors.centerIn: parent

        border {
            color: Theme.highlightColor
            width: 5
        }
        z: 1
        color: "transparent"
        visible: anchorContainer.visible
        opacity: overlay._captureButtonLocation == index ? anchorContainer.opacity : 1.0
    }
}
