import QtQuick 1.2
import Sailfish.Silica 1.0

MouseArea {
    id: item

    property bool selected: panel.currentItem == item
    property url icon

    width: theme.itemSizeExtraLarge
    height: theme.itemSizeExtraLarge

    Image {
        anchors.centerIn: parent

        source: item.selected
                ? icon + "?" + theme.highlightColor
                : icon
    }

    onClicked: {
        panel.currentItem = item
        panel.open = false
    }
}
