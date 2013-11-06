import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    id: menuItem

    property url icon
    property variant value

    property string property
    property QtObject settings

    readonly property bool selected: settings[property] == value

    width: parent.width
    height: (Screen.width - (Theme.fontSizeExtraSmall * 2) - (3 * Theme.paddingLarge)) / 5

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
        width: Theme.itemSizeExtraSmall * 0.8
        height: Theme.itemSizeExtraSmall * 0.8

        anchors.centerIn: parent
        source: menuItem.pressed
                ? menuItem.icon + "?" + Theme.highlightColor
                : menuItem.icon
        smooth: true
    }
}
