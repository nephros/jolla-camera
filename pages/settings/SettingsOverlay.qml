import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0

PinchArea {
    id: overlay

    property bool isPortrait
    property bool open
    property bool inButtonLayout
    readonly property bool expanded: open || _closing || verticalAnimation.running || dragArea.drag.active
    default property alias _data: container.data

    readonly property int _captureButtonLocation: overlay.isPortrait
                ? Settings.global.portraitCaptureButtonLocation
                : Settings.global.landscapeCaptureButtonLocation

    readonly property int timerAlignment: timerContainer.parent == timerAnchorBL
                ? Qt.AlignLeft
                : Qt.AlignRight

    property real _lastPos
    property real _direction

    property real _progress: (panel.y + panel.height) / panel.height
    property bool _closing

    property bool interactive: true

    property alias shutter: shutterContainer.children
    property alias timer: timerContainer.children

    on_CaptureButtonLocationChanged: inButtonLayout = false

    property list<SettingsMenuItem> _menus
    _menus: [
        captureModeMenu.currentItem,
        flashMenu.currentItem,
        whiteBalanceMenu.currentItem,
        focusMenu.currentItem
    ]

    signal clicked(var mouse)

    function _close() {
        _closing = true
        open = false
        inButtonLayout = false
        _closing = false
    }

    property list<Item> _buttonAnchors
    _buttonAnchors: [
        ButtonAnchor { id: buttonAnchorTL; index: 0; anchors { left: parent.left; top: parent.top } visible: !overlay.isPortrait },
        ButtonAnchor { id: buttonAnchorCL; index: 1; anchors { left: parent.left; verticalCenter: parent.verticalCenter } },
        ButtonAnchor { id: buttonAnchorBL; index: 2; anchors { left: parent.left; bottom: parent.bottom } },
        ButtonAnchor { id: buttonAnchorBC; index: 3; anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom } },
        ButtonAnchor { id: buttonAnchorBR; index: 4; anchors { right: parent.right; bottom: parent.bottom } },
        ButtonAnchor { id: buttonAnchorCR; index: 5; anchors { right: parent.right; verticalCenter: parent.verticalCenter } },
        ButtonAnchor { id: buttonAnchorTR; index: 6; anchors { right: parent.right; top: parent.top } visible: !overlay.isPortrait }
    ]

    Item {
        id: shutterContainer

        parent: overlay._buttonAnchors[overlay._captureButtonLocation]
        anchors.fill: parent
    }

    Item {
        id: timerContainer

        parent: overlay.isPortrait
                        ? (shutterContainer.parent != buttonAnchorBR ? timerAnchorBR : timerAnchorBL)
                        : (shutterContainer.parent != buttonAnchorTR ? timerAnchorTR : timerAnchorBR)
        anchors.fill: parent
    }

    MouseArea {
        id: dragArea

        width: overlay.width
        height: overlay.height

        drag {
            target: overlay.interactive && !overlay.inButtonLayout ? panel : undefined
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

        MouseArea {
            id: container

            width: overlay.width
            height: overlay.height
            opacity: Math.min(1 - overlay._progress, 1 - anchorContainer.opacity)

            onClicked: {
                if (overlay.expanded) {
                    overlay.open = false
                } else if (overlay.inButtonLayout) {
                    overlay.inButtonLayout = false
                } else {
                    overlay.clicked(mouse)
                }
            }

            onPressAndHold: {
                overlay.inButtonLayout = true
            }

            Rectangle {
                width: overlay.width
                height: Theme.itemSizeSmall

                gradient: Gradient {
                    GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightDimmerColor, 0.6) }
                    GradientStop { position: 0.9; color: Theme.rgba(Theme.highlightDimmerColor, 0.2) }
                    GradientStop { position: 1.0; color: Theme.rgba(Theme.highlightDimmerColor, 0.0) }
                }
            }

            MouseArea {
                anchors.horizontalCenter: parent.horizontalCenter
                width: row.width
                height: Theme.itemSizeLarge
                enabled: !overlay.expanded && !overlay.inButtonLayout

                onClicked: overlay.open = true
            }

            TimerAnchor { id: timerAnchorBL; anchors { left: parent.left; bottom: parent.bottom } }
            TimerAnchor { id: timerAnchorBR; anchors { right: parent.right; bottom: parent.bottom } }
            Item {
                id: timerAnchorTR
                width: Theme.itemSizeMedium
                height: Theme.itemSizeSmall
                anchors { right: parent.right; top: parent.top; rightMargin: Theme.paddingLarge }
            }
        }

        Item {
            id: panel

            Binding {
                target: panel
                property: "y"
                value: open ? 0 : -panel.height
                when: expandBehavior.enabled
            }
            Behavior on y {
                id: expandBehavior
                enabled: !dragArea.drag.active
                NumberAnimation {
                    id: verticalAnimation
                    duration: 200; easing.type: Easing.InOutQuad
                }
            }

            width: overlay.width
            height: Screen.width / 2
        }

        Rectangle {
            id: highlight
            width: overlay.width
            height: overlay.height

            visible: overlay.expanded
            color: Theme.highlightDimmerColor
            opacity: 0.6 * (1 - container.opacity)
        }

        Row {
            id: row

            y: height * panel.y / panel.height
            anchors.horizontalCenter: parent.horizontalCenter

            width: Screen.width
            height: overlay.height

            opacity: 1 - container.opacity

            enabled: overlay.expanded

            SettingsMenu {
                id: captureModeMenu

                title: Settings.captureModeText(Settings.global.captureMode)
                model: [ "image", "video" ]
                delegate: SettingsMenuItem {
                    property: "captureMode"
                    settings: Settings.global
                    value: modelData
                    icon: Settings.captureModeIcon(modelData)
                }
            }
            SettingsMenu {
                id: flashMenu

                title: Settings.flashText(Settings.mode.flash)
                model: Settings.mode.flashValues
                delegate: SettingsMenuItem {
                    settings: Settings.mode
                    property: "flash"
                    value: modelData
                    icon: Settings.flashIcon(modelData)
                }
            }
            SettingsMenu {
                id: whiteBalanceMenu

                title: Settings.whiteBalanceText(Settings.mode.whiteBalance)
                model: Settings.mode.whiteBalanceValues
                delegate: SettingsMenuItem {
                    settings: Settings.mode
                    property: "whiteBalance"
                    value: modelData
                    icon: Settings.whiteBalanceIcon(modelData)
                }
            }
            SettingsMenu {
                id: focusMenu

                title: Settings.focusDistanceText(Settings.mode.focusDistance)
                model: Settings.mode.focusDistanceValues
                delegate: SettingsMenuItem {
                    settings: Settings.mode
                    property: "focusDistance"
                    value: modelData
                    icon: Settings.focusDistanceIcon(modelData)
                }
            }
        }

        Column {
            id: switcherColumn

            opacity: row.opacity
            anchors {
                right: parent.right
                bottom: row.bottom
                rightMargin: Theme.paddingLarge
                bottomMargin: Theme.paddingLarge * 2
            }

            width: Screen.width / 4

            Label {
                x: Theme.paddingSmall
                width: parent.width - (2 * Theme.paddingSmall)
                height: (Theme.fontSizeExtraSmall * 2) + Theme.paddingLarge

                color: Theme.highlightBackgroundColor
                font {
                    pixelSize: Theme.fontSizeExtraSmall
                    capitalization: Font.Capitalize
                }
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter

                text: Settings.global.cameraDevice == "primary"
                        //% "Main camera"
                        ? qsTrId("camera-la-main-camera")
                        //% "Front camera"
                        : qsTrId("camera-la-front-camera")
            }

            Item {
                width: parent.width
                height: (Screen.width - (Theme.fontSizeExtraSmall * 2) - (3 * Theme.paddingLarge)) / 5

                Image {
                    width: Theme.itemSizeExtraSmall * 0.8
                    height: Theme.itemSizeExtraSmall * 0.8

                    anchors.centerIn: parent
                    source: "image://theme/icon-camera-front-camera"
                                + (switcher.pressed ? "?" + Theme.highlightColor : "")
                    smooth: true
                }
            }
        }
        MouseArea {
            id: switcher

            anchors.fill: switcherColumn
            onClicked: {
                Settings.global.cameraDevice = Settings.global.cameraDevice == "primary"
                        ? "secondary"
                        : "primary"
            }
        }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter

        Repeater {
            model: overlay._menus
            delegate: Item {
                id: statusItem

                y: model.y != undefined
                        ? Math.max(0, row.y + model.y)
                        : 0

                width: Screen.width / 4
                height: (Screen.width - (Theme.fontSizeExtraSmall * 2) - (3 * Theme.paddingLarge)) / 5

                Image {
                    width: Theme.itemSizeExtraSmall * 0.8
                    height: Theme.itemSizeExtraSmall * 0.8

                    anchors.centerIn: parent
                    source: model.icon != undefined
                            ? model.icon + "?" + Theme.highlightColor
                            : ""
                    smooth: true
                }
            }
        }
    }

    Item {
        id: anchorContainer

        width: overlay.width
        height: overlay.height

        visible: overlay.inButtonLayout || layoutAnimation.running
        opacity: overlay.inButtonLayout ? 1.0 : 0.0
        Behavior on opacity { FadeAnimation { id: layoutAnimation } }

        Rectangle {
            id: layoutHighlight

            width: overlay.width
            height: overlay.height

            opacity: 0.8
            color: Theme.highlightDimmerColor
        }

        Label {
            anchors {
                centerIn: parent
                verticalCenterOffset: -Theme.paddingLarge
            }
            width: overlay.isPortrait
                    ? Screen.width - (2 * Theme.itemSizeExtraLarge)
                    : Screen.width - Theme.itemSizeExtraLarge
            font.pixelSize: Theme.fontSizeExtraLarge
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            color: Theme.highlightColor

            text: overlay.isPortrait
                    //% "Select location for the portrait capture key"
                    ? qsTrId("camera-la-portrait-capture-key-location")
                    //% "Select location for the landscape capture key"
                    : qsTrId("camera-la-landscape-capture-key-location")
        }
    }
}
