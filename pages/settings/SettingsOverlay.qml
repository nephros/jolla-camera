import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera 1.0

PinchArea {
    id: overlay

    property bool isPortrait
    property bool open
    property bool inButtonLayout
    property bool pinchActive
    readonly property bool expanded: open
                || _closing
                || verticalAnimation.running
                || dragArea.drag.active
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
    property alias exposure: exposureMenu.children

    readonly property int exposureAlignment: shutterContainer.parent == timerAnchorBR
                ? Qt.AlignRight
                : Qt.AlignLeft

    readonly property real _menuWidth: isPortrait ? Screen.width / 4 : Screen.height / 8

    on_CaptureButtonLocationChanged: inButtonLayout = false

    onIsPortraitChanged: {
        upperHeader.pressedMenu = null
        lowerHeader.pressedMenu = null
    }

    property list<SettingsMenuItem> _menus
    _menus: [
        captureModeMenu.currentItem,
        flashMenu.currentItem,
        whiteBalanceMenu.currentItem,
        focusMenu.currentItem
    ]

    signal clicked(var mouse)

    function close() {
        _closing = true
        exposureMenu.open = false
        open = false
        inButtonLayout = false
        _closing = false
    }

    onPinchStarted: pinchActive = true
    onPinchFinished: pinchActive = false

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
        enabled: !overlay.open && !overlay.inButtonLayout
    }

    ExposureMenu {
        id: exposureMenu

        parent: shutterContainer.parent == buttonAnchorBL
                    || shutterContainer.parent == buttonAnchorCL
                    || shutterContainer.parent == buttonAnchorTL
                ? timerAnchorBR
                : timerAnchorBL
        alignment: parent == timerAnchorBR ? Qt.AlignRight : Qt.AlignLeft
    }

    Item {
        id: timerContainer

        parent: {
            if (overlay.isPortrait) {
                if (exposureMenu.parent == timerAnchorBR
                        && shutterContainer.parent != buttonAnchorBL) {
                    return timerAnchorBL
                } else if (exposureMenu.parent == timerAnchorBL
                            && shutterContainer.parent != buttonAnchorBR) {
                    return timerAnchorBR
                } else {
                    return timerAnchorBC
                }
            } else {
                if (exposureMenu.parent == timerAnchorBR) {
                    return shutterContainer.parent == buttonAnchorTL
                            ? timerAnchorBL
                            : timerAnchorTL
                } else if (shutterContainer.parent == buttonAnchorTR) {
                    return timerAnchorBR
                } else {
                    return timerAnchorTR
                }
            }
        }
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

            property real pressX
            property real pressY

            width: overlay.width
            height: overlay.height
            opacity: Math.min(1 - overlay._progress, 1 - anchorContainer.opacity)
            enabled: !overlay.pinchActive

            onPressed: {
                pressX = mouseX
                pressY = mouseY
            }

            onClicked: {
                if (exposureMenu.expanded) {
                    exposureMenu.open = false
                } else if (overlay.expanded) {
                    overlay.open = false
                } else if (overlay.inButtonLayout) {
                    overlay.inButtonLayout = false
                } else {
                    overlay.clicked(mouse)
                }
            }

            onPressAndHold: {
                if (!overlay.open) {
                    var dragDistance = Math.max(Math.abs(mouseX - pressX),
                                                Math.abs(mouseY - pressY))
                    if (dragDistance < Theme.startDragDistance) {

                        overlay.inButtonLayout = true
                    }
                }
            }

            Rectangle {
                width: overlay.width
                height: Theme.itemSizeMedium

                gradient: Gradient {
                    GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightDimmerColor, 0.6) }
                    GradientStop { position: 1.0; color: Theme.rgba(Theme.highlightDimmerColor, 0.0) }
                }
            }

            MouseArea {
                anchors.horizontalCenter: parent.horizontalCenter
                width: row.width
                height: Theme.itemSizeLarge
                enabled: !overlay.expanded && !overlay.inButtonLayout

                onClicked: overlay.open = true

                onPressAndHold: container.pressAndHold(mouse)
            }

            TimerAnchor { id: timerAnchorBL; anchors { left: parent.left; bottom: parent.bottom } }
            TimerAnchor { id: timerAnchorBC; anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom } }
            TimerAnchor { id: timerAnchorBR; anchors { right: parent.right; bottom: parent.bottom } }
            Item {
                id: timerAnchorTL
                width: Theme.itemSizeMedium
                height: Theme.itemSizeSmall
                anchors { left: parent.left; top: parent.top; leftMargin: Theme.paddingLarge }
            }
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

        TitleHighlight {
            anchors { left: row.left; top: row.top; right: row.right }
            opacity: row.opacity
        }

        Row {
            id: row

            y: height * panel.y / panel.height
            anchors.horizontalCenter: parent.horizontalCenter

            height: 6 * Theme.itemSizeSmall

            opacity: 1 - container.opacity

            enabled: overlay.expanded
            visible: overlay.expanded

            SettingsMenu {
                id: captureModeMenu

                width: overlay._menuWidth
                title: Settings.captureModeText
                header: upperHeader
                model: [ "image", "video" ]
                delegate: SettingsMenuItem {
                    property: "captureMode"
                    settings: Settings.global
                    value: modelData
                    icon: Settings.captureModeIcon(modelData)
                    iconVisible: !selected
                }
            }
            SettingsMenu {
                id: flashMenu

                width: overlay._menuWidth
                title: Settings.flashText
                header: upperHeader
                model: Settings.mode.flashValues
                delegate: SettingsMenuItem {
                    settings: Settings.mode
                    property: "flash"
                    value: modelData
                    icon: Settings.flashIcon(modelData)
                    iconVisible: !selected
                }
            }
            SettingsMenu {
                id: whiteBalanceMenu

                width: overlay._menuWidth
                title: Settings.whiteBalanceText
                header: upperHeader
                model: Settings.mode.whiteBalanceValues
                delegate: SettingsMenuItem {
                    settings: Settings.mode
                    property: "whiteBalance"
                    value: modelData
                    icon: Settings.whiteBalanceIcon(modelData)
                    iconVisible: !selected
                }
            }
            SettingsMenu {
                id: focusMenu

                width: overlay._menuWidth
                title: Settings.focusDistanceText
                header: upperHeader
                model: Settings.mode.focusDistanceValues
                delegate: SettingsMenuItem {
                    settings: Settings.mode
                    property: "focusDistance"
                    value: modelData
                    icon: Settings.focusDistanceIcon(modelData)
                    iconVisible: !selected
                }
            }
        }

        TitleHighlight {
            anchors { left: leftRow.left; top: leftRow.top; right: leftRow.right }
            opacity: row.opacity
        }
        TitleHighlight {
            anchors { left: rightRow.left; top: rightRow.top; right: rightRow.right }
            opacity: row.opacity
        }

        Row {
            id: leftRow
            anchors {
                top: overlay.isPortrait ? row.bottom : row.top
                right: overlay.isPortrait ? row.horizontalCenter : row.left
            }

            opacity: row.opacity
            visible: overlay.expanded

            SettingsMenu {
                id: isoMenu

                width: overlay._menuWidth
                title: Settings.isoText
                header: overlay.isPortrait ? lowerHeader : upperHeader
                model: Settings.mode.isoValues
                delegate: SettingsMenuItem {
                    settings: Settings.mode
                    property: "iso"
                    value: modelData
                    icon: Settings.isoIcon(modelData)
                }
            }
            SettingsMenu {
                id: gridMenu

                width: overlay._menuWidth
                title: Settings.viewfinderGridText
                header: overlay.isPortrait ? lowerHeader : upperHeader
                model: Settings.mode.viewfinderGridValues
                delegate: SettingsMenuItem {
                    settings: Settings.mode
                    property: "viewfinderGrid"
                    value: modelData
                    icon: Settings.viewfinderGridIcon(modelData)
                }
            }
        }

        Row {
            id: rightRow
            anchors {
                top: overlay.isPortrait ? row.bottom : row.top
                left: overlay.isPortrait ? row.horizontalCenter : row.right
            }

            opacity: row.opacity
            visible: overlay.expanded

            SettingsMenu {
                id: timerMenu

                width: overlay._menuWidth
                title: Settings.timerText
                header: overlay.isPortrait ? lowerHeader : upperHeader
                model: Settings.mode.timerValues
                delegate: SettingsMenuItem {
                    settings: Settings.mode
                    property: "timer"
                    value: modelData
                    icon: Settings.timerIcon(modelData)
                }
            }

            SettingsMenu {
                id: cameraDeviceMenu
                width: overlay._menuWidth
                title: Settings.cameraText
                header: overlay.isPortrait ? lowerHeader : upperHeader
                model: [ "primary", "secondary" ]
                delegate: SettingsMenuItem {
                    settings: Settings.global
                    property: "cameraDevice"
                    value: modelData
                    icon: Settings.cameraIcon(modelData)
                }
            }
        }

        HeaderLabel {
            id: upperHeader

            anchors { left: parent.left; top: row.top; right: parent.right }
            opacity: row.opacity
        }

        HeaderLabel {
            id: lowerHeader

            anchors { left: parent.left; top: row.bottom; right: parent.right }
            opacity: row.opacity
        }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter

        Repeater {
            model: overlay._menus
            delegate: Item {
                id: statusItem

                y: model.y != undefined
                        ? Math.max(0, row.y + model.y + Theme.itemSizeSmall)
                        : 0

                width: overlay._menuWidth
                height: Theme.itemSizeSmall

                Image {
                    anchors.centerIn: parent
                    source: model.icon != undefined && model.icon != ""
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
            textFormat: Text.AutoText
            color: Theme.highlightColor

            text: overlay.isPortrait
                    //% "Select location for the portrait capture key"
                    ? qsTrId("camera-la-portrait-capture-key-location")
                    //% "Select location for the landscape capture key"
                    : qsTrId("camera-la-landscape-capture-key-location")
        }
    }
}
