import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    property alias title: titleText.text
    property alias model: repeater.model
    property alias delegate: repeater.delegate
    property Item currentItem

    width: Theme.itemSizeLarge

    Label {
        id: titleText

        width : Theme.itemSizeLarge
        height: Theme.itemSizeExtraSmall

        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeTiny
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
    }

    Repeater {
        id: repeater
    }
}
