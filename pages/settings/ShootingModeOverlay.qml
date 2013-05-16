import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0

Item {
    id: overlay

    property Camera camera
    property bool open
    property bool expanded: open || verticalAnimation.running || dragArea.drag.active
    property int orientation
    default property alias _data: container.data
    property Item _currentItem: globalSettings.shootingMode == "front-camera"
                ? frontMode
                : row[globalSettings.shootingMode]

    property real _lastPos
    property real _direction

    property bool interactive: true

    MouseArea {
        id: dragArea

        width: overlay.width
        height: overlay.height

        enabled: overlay.interactive
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

        onClicked: overlay.open = false

        Item {
            id: container

            width: overlay.width
            height: overlay.height
            opacity: 1 - ((panel.y + panel.height) / panel.height)
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
            height: overlay.height / 3
        }

        Rectangle {
            id: highlight
            y: height * panel.y / panel.height
            width: overlay.width
            height: overlay.orientation == Orientation.Landscape
                    ? overlay.height / 2
                    : overlay.height

            visible: overlay.expanded
            color: theme.highlightDimmerColor
            opacity: 0.6 * (1 - container.opacity)
        }

        Flow {
            id: row

            // This effectively creates a map through which the mode items can be looked up by name.
            property alias automatic: automaticMode
            property alias program: programMode
            property alias macro: macroMode
            property alias sports: sportsMode
            property alias landscape: landscapeMode
            property alias portrait: portraitMode

            width: overlay.orientation == Orientation.Portrait
                    ? theme.iconSizeLarge
                    : overlay.width - 116
            height: overlay.orientation == Orientation.Landscape
                    ? theme.iconSizeLarge
                    : overlay.height - 116
            anchors {
                top: overlay.orientation == Orientation.Portrait
                        ? highlight.top
                        : highlight.verticalCenter
                horizontalCenter: panel.horizontalCenter
                topMargin: overlay.orientation == Orientation.Portrait
                        ? 58
                        : 0
            }
            opacity: 1 - container.opacity

            spacing: Math.floor((screen.height - 116 - (theme.iconSizeLarge * 7)) / 6)

            ShootingModeItem { id: automaticMode; mode: "automatic" }
            ShootingModeItem { id: programMode; mode: "program" }
            ShootingModeItem { id: macroMode; mode: "macro" }
            ShootingModeItem { id: sportsMode; mode: "sports" }
            ShootingModeItem { id: frontMode; mode: "front-camera" }
            ShootingModeItem { id: landscapeMode; mode: "landscape" }
            ShootingModeItem { id: portraitMode; mode: "portrait" }
        }

        MouseArea {
            enabled: overlay.interactive && !overlay.expanded
            x: row.x + overlay._currentItem.x
            y: Math.max(theme.paddingLarge, row.y + overlay._currentItem.y)
            width: theme.iconSizeLarge
            height: theme.iconSizeLarge
            onClicked: overlay.open = !overlay.open

            Image {
                anchors.centerIn: parent
                source: overlay._currentItem.selectionIcon

            }
        }
    }
}
