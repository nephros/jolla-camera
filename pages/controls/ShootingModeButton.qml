import QtQuick 1.2
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

CircularButton {
    id: button

    property ShootingModePanel panel

    diameter: theme.itemSizeLarge
    opacity: 1.0 - (panel.visibleSize / panel.height)

    onClicked: panel.show()

    Image {
        anchors.centerIn: parent

        source: panel.currentIcon
    }
}
