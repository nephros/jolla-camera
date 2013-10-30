import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    id: menuItem

    property url icon
    property variant value

    property string property
    property QtObject settings

    readonly property bool selected: settings[property] == value

    width: Theme.itemSizeLarge
    height: Theme.itemSizeSmall

    opacity: selected ? 0 : 1

    onSelectedChanged: {
        if (selected) {
            parent.currentItem = menuItem
        }
    }

    onClicked: {
        settings[property] = value
    }

    Image {
        width: Theme.iconSizeSmall
        height: Theme.iconSizeSmall

        anchors.centerIn: parent
        source: menuItem.pressed
                ? menuItem.icon + "?" + Theme.highlightColor
                : menuItem.icon
        smooth: true
    }
}
