import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.camera.settings 1.0

MouseArea {
    property int index

    anchors.margins: Theme.paddingLarge

    width: Theme.itemSizeMedium
    height: Theme.itemSizeMedium

    z: 1

    opacity: layoutHighlight.opacity
    visible: layoutHighlight.visible && Settings.global.captureButtonLocation != index

    onClicked: Settings.global.captureButtonLocation = index

    Rectangle {
        radius: Theme.itemSizeMedium / 2
        width: Theme.itemSizeMedium
        height: Theme.itemSizeMedium

        color: Theme.highlightColor
    }
}
