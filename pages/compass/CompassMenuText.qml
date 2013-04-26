import QtQuick 1.1
import Sailfish.Silica 1.0

BackgroundItem {
    property alias label: labelItem.text

    width: parent.width
    height: labelItem.implicitHeight + theme.paddingMedium

    onClicked: parent._compass.closeMenu()

    Label {
        id: labelItem
        text: delay
        font.pixelSize: theme.fontSizeLarge
        anchors.centerIn: parent
    }
}
