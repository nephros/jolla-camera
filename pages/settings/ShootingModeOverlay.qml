import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

Item {
    id: overlay

    property Camera camera
    property bool open
    property bool expanded: open || _closing || verticalAnimation.running || dragArea.drag.active
    property bool isPortrait: true
    default property alias _data: container.data
    property Item _currentItem: Settings.global.shootingMode == "front-camera"
                ? frontMode
                : row[Settings.global.shootingMode]

    property real _lastPos
    property real _direction

    property real _progress: (panel.y + panel.height) / panel.height
    property bool _closing

    property bool interactive: true

    signal clicked(var mouse)

    function _close() {
        _closing = true
        open = false
        _closing = false
    }

    MouseArea {
        id: dragArea

        width: overlay.width
        height: overlay.height

        drag {
            target: overlay.interactive ? panel : undefined
            minimumY: -panel.height
            maximumY: 0
            axis: Drag.YAxis
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

        onClicked: {
            if (overlay.expanded) {
                overlay.open = false
            } else {
                overlay.clicked(mouse)
            }
        }

        Item {
            id: container

            width: overlay.width
            height: overlay.height
            opacity: 1 - overlay._progress
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
            width: overlay.width
            height: !overlay.isPortrait
                    ? overlay.height / 2
                    : overlay.height

            visible: overlay.expanded
            color: Theme.highlightDimmerColor
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


            y: overlay.isPortrait
                    ? Theme.paddingLarge + height * panel.y / panel.height
                    : (highlight.height - height) * overlay._progress / 2

            width: overlay.isPortrait
                    ? Theme.iconSizeMedium
                    : undefined
            height: !overlay.isPortrait
                    ? Theme.iconSizeMedium
                    : undefined
            anchors.horizontalCenter: panel.horizontalCenter

            opacity: 1 - container.opacity
            spacing: Math.floor((screen.height - 116 - (Theme.iconSizeMedium * 7)) / 6)

            // The hardware integration only supports a limited set of options at the moment,
            // so only the automatic and front-camera modes are available.
            ShootingModeItem { id: automaticMode; mode: "automatic" }
            ShootingModeItem { id: programMode; mode: "program"; visible: Settings.global.enableExtendedModes }
            ShootingModeItem { id: macroMode; mode: "macro"; visible: Settings.global.enableExtendedModes }
            ShootingModeItem { id: sportsMode; mode: "sports"; visible: Settings.global.enableExtendedModes }
            ShootingModeItem { id: frontMode; mode: "front-camera" }
            ShootingModeItem { id: landscapeMode; mode: "landscape"; visible: Settings.global.enableExtendedModes }
            ShootingModeItem { id: portraitMode; mode: "portrait"; visible: Settings.global.enableExtendedModes }
        }

        MouseArea {
            enabled: overlay.interactive && !overlay.expanded
            x: row.x + overlay._currentItem.x
            y: Math.max(Theme.paddingLarge, row.y + overlay._currentItem.y)
            width: Theme.iconSizeMedium
            height: Theme.iconSizeMedium

            onClicked: overlay.open = !overlay.open

            Image {
                anchors.centerIn: parent
                source: overlay._currentItem.selectionIcon

            }
        }
    }
}
