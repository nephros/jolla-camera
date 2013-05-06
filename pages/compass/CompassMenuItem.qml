import QtQuick 1.1
import Sailfish.Silica 1.0

MouseArea {
    id: menuItem

    property url icon: image.source
    property variant value

    property bool selected: settings[parent._property] == value

    width: parent.width
    height: image.height + theme.paddingLarge

    onClicked: {
        settings[parent._property] = value
        parent._compass.closeMenu()
    }

    Image {
        id: image

        anchors.centerIn: parent
        source: menuItem.selected || menuItem.pressed
                ? menuItem.icon + "?" + theme.highlightColor
                : menuItem.icon
        smooth: true
    }
}
