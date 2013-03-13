import QtQuick 1.1
import Sailfish.Silica 1.0

DockedPanel {
    id: panel

    width: theme.paddingLarge + (panel.dock == Dock.Top ? flow.width : theme.itemSizeExtraLarge)
    height: theme.paddingLarge + (panel.dock == Dock.Right ? flow.height : theme.itemSizeExtraLarge)

    signal openSettings
    signal openGallery

    Flow {
        id: flow
        x: theme.paddingLarge
        y: theme.paddingLarge
        width: panel.dock == Dock.Right ? theme.itemSizeExtraLarge : undefined
        height: panel.dock == Dock.Top ? theme.itemSizeExtraLarge : undefined
        spacing: theme.paddingLarge
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
