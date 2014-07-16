import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    id: menuItem

    property url icon
    property variant value
    property alias iconVisible: image.visible

    property string property
    property QtObject settings

    property bool selected: settings[property] == value

    width: parent.width
    height: Theme.itemSizeSmall

    onSelectedChanged: {
        if (selected) {
            parent.currentItem = menuItem
        }
    }

    onPressed: {
        parent.pressedItem = menuItem
    }

    onClicked: {
        settings[property] = value
    }

    Rectangle {
        anchors.centerIn: parent
        width: Theme.iconSizeMedium
        height: Theme.iconSizeMedium

        radius: width / 2

        color: Theme.highlightBackgroundColor

        opacity: menuItem.selected || menuItem.pressed ? 0.3 : 0.0
        Behavior on opacity { FadeAnimation {} }
    }

    Image {
        id: image

        anchors.centerIn: parent
        source: menuItem.pressed || menuItem.selected
                ? menuItem.icon + "?" + Theme.highlightColor
                : menuItem.icon
        smooth: true
    }
}
