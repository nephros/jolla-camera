import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    id: menuItem

    property url icon
    property variant value

    property string property
    property QtObject settings

    property bool selected: settings[property] == value

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
        anchors.centerIn: parent
        source: menuItem.pressed || menuItem.selected
                ? menuItem.icon + "?" + Theme.highlightColor
                : menuItem.icon
        smooth: true
    }
}
