import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    id: menu

    property alias title: titleText.text
    property alias model: repeater.model
    property alias delegate: repeater.delegate
    property Item currentItem

    width: Screen.width / 4

    Item {
        width: 1
        height: Theme.paddingLarge
    }

    Label {
        id: titleText

        x: Theme.paddingSmall
        width : parent.width - (2 * Theme.paddingSmall)
        height: (Theme.fontSizeExtraSmall * 2) + Theme.paddingLarge

        color: Theme.highlightBackgroundColor
        font {
            pixelSize: Theme.fontSizeExtraSmall
        }
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }

    Repeater {
        id: repeater
    }
}
