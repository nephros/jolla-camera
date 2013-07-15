import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    id: menuItem

    property url icon: image.source
    property variant value

    property bool selected: parent._settings[parent._property] == value

    width: parent.width
    height: Theme.itemSizeSmall

    onClicked: {
        parent._settings[parent._property] = value
        parent._compass.closeMenu()
    }

    Image {
        id: image

        anchors.centerIn: parent
        source: menuItem.selected || menuItem.pressed
                ? menuItem.icon + "?" + Theme.highlightColor
                : menuItem.icon
        smooth: true
    }
}
