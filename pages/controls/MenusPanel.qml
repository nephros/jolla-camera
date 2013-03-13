import QtQuick 1.1
import Sailfish.Silica 1.0

DockedPanel {
    width: row.width
    height: theme.paddingLarge + theme.itemSizeExtraLarge
    dock: Dock.Top

    signal openSettings
    signal openGallery

    Row {
        id: row
        x: theme.paddingLarge
        height: theme.itemSizeExtraLarge
        spacing: theme.paddingLarge
        anchors.bottom: parent.bottom
        IconButton {
            // ### Settings icon
            icon.source: "image://theme/icon-m-developer-mode"

            onClicked: openSettings()
        }

        IconButton {
            // ### gallery icon
            icon.source: "image://theme/icon-m-share"

            onClicked: openGallery()
        }
    }
}
