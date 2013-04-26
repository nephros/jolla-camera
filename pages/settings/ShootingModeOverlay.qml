import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0

Item {
    id: overlay

    property Camera camera
    property alias open: panel.open
    property alias expanded: panel.expanded
    default property alias _data: container.data
    property Item _currentItem: row.children[settings.shootingMode]

    property bool interactive: true

    Rectangle {
        width: overlay.width
        height: overlay.height

        visible: panel.expanded
        color: theme.highlightBackgroundColor
        opacity: 0.5 * panel.visibleSize / panel.height
    }

    DockedPanel {
        id: panel

        dock: Dock.Top

        width: overlay.width
        height: theme.itemSizeExtraLarge

        Row {
            id: row

            height: panel.height
            anchors.centerIn: parent

            spacing: theme.paddingMedium

            ShootingModeItem {
                mode: Settings.Auto
                icon: "image://theme/icon-camera-automatic"
            }
            ShootingModeItem {
                mode: Settings.Program
                icon: "image://theme/icon-camera-program"
            }
            ShootingModeItem {
                mode: Settings.Macro
                icon: "image://theme/icon-camera-macro"
            }
            ShootingModeItem {
                mode: Settings.Sports
                icon: "image://theme/icon-camera-sports"
            }
            ShootingModeItem {
                mode: Settings.Landscape
                icon: "image://theme/icon-camera-landscape"
            }
            ShootingModeItem {
                mode: Settings.Portrait
                icon: "image://theme/icon-camera-portrait"
            }
        }
    }

    Item {
        id: container

        y: panel.visibleSize
        width: overlay.width
        height: overlay.height

        opacity: 1 - 0.6 * panel.visibleSize / panel.height
    }

    Image {
        x: row.x + overlay._currentItem.x + (overlay._currentItem.width - width) / 2
        y: theme.paddingMedium
        opacity: 1 - panel.visibleSize / panel.height

        source: overlay._currentItem.selectionIcon

        width: implicitWidth * 0.75
        height: implicitHeight * 0.75

        MouseArea {
            enabled: overlay.interactive && !overlay.expanded
            anchors.fill: parent
            anchors.margins: -parent.width / 4
            onClicked: panel.open = true
        }
    }
}
