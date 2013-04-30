import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0

Item {
    id: overlay

    property Camera camera
    property bool open
    property bool expanded: open || verticalAnimation.running
    default property alias _data: container.data
    property Item _currentItem: row.children[settings.shootingMode]

    property real _lastPos
    property real _direction

    property bool interactive: true

    Rectangle {
        width: overlay.width
        height: overlay.height

        visible: panel.expanded
        color: theme.highlightBackgroundColor
        opacity: 0.5 * panel.visibleSize / panel.height
    }

    MouseArea {
        id: dragArea

        width: overlay.width
        height: overlay.height

        drag {
            target: panel
            minimumY: -panel.height
            maximumY: 0
            axis: Drag.YAxis
            filterChildren: true
            onActiveChanged: {
                if (!drag.active && panel.y < -(panel.height / 3) && overlay._direction <= 0) {
                    overlay.open = false
                } else if (!drag.active && panel.y > (-panel.height * 2 / 3) && overlay._direction >= 0) {
                    overlay.open = true
                }
            }
        }

        onPressed: {
            overlay._direction = 0
            overlay._lastPos = panel.y
        }
        onPositionChanged: {
            var pos = panel.y
            overlay._direction = (overlay._direction + pos - _lastPos) / 2
            overlay._lastPos = panel.y
        }

        Item {
            id: panel

            Binding {
                target: panel
                property: "y"
                value: open ? 0 : -panel.height
                when: !dragArea.drag.active
            }
            Behavior on y {
                enabled: !dragArea.drag.active
                NumberAnimation {
                    id: verticalAnimation
                    duration: 200; easing.type: Easing.InOutQuad
                }
            }

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

            y: panel.y + panel.height
            width: overlay.width
            height: overlay.height
            opacity: 1 - 0.6 * container.y / panel.height
        }

        Image {
            x: row.x + overlay._currentItem.x + (overlay._currentItem.width - width) / 2
            y: theme.paddingMedium
            opacity: 1 - container.y / panel.height

            source: overlay._currentItem.selectionIcon

            MouseArea {
                enabled: overlay.interactive && !overlay.expanded
                anchors.fill: parent
                anchors.margins: -parent.width / 4
                onClicked: overlay.open = true
            }
        }
    }
}
