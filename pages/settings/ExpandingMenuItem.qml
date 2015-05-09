import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    id: menuItem

    property url icon
    property variant value

    property string property
    property QtObject settings

    property QtObject menu

    readonly property bool selected: settings[property] == value
    readonly property bool highlighted: (parent.open || parent.pressed) && (selected || menuItem.pressed)

    width: parent.width
    height: selected ? parent.width : parent.itemHeight

    onSelectedChanged: {
        if (selected && parent) {
            parent.currentItem = menuItem
        }
    }

    onParentChanged: {
        if (selected && parent) {
            parent.currentItem = menuItem
        }
    }

    onClicked: {
        settings[property] = value
        menuItem.parent.open = false
    }

    Item {
        anchors.fill: parent

        opacity: menuItem.selected || !menuItem.parent ? 1.0 : menuItem.parent.itemOpacity
        visible: menuItem.selected || (menuItem.parent && menuItem.parent.itemsVisible)

        Rectangle {
            anchors.centerIn: parent

            width: Theme.itemSizeSmall
            height: Theme.itemSizeSmall

            radius: width / 2

            color: menuItem.highlighted
                   ? Theme.highlightColor
                   : "black"
            Behavior on color {
                ColorAnimation { duration: 200 }
            }

           opacity: menuItem.highlighted ? 0.2 : 0.4
           Behavior on opacity { FadeAnimation {} }
        }

        Image {
            anchors.centerIn: parent
            source: menuItem.highlighted
                    ? menuItem.icon
                    : menuItem.icon + "?" + Theme.highlightColor
        }
    }
}
