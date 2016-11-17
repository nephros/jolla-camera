import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

PinchArea {
    id: overlay

    property bool isPortrait
    property real topButtonRowHeight
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

    property real _lastPos
    property real _direction

    property real _progress: (panel.y + panel.height) / panel.height
    property bool _closing

    property real _menuItemHorizontalSpacing: Screen.sizeCategory >= Screen.Large
                                              ? Theme.paddingLarge * 2
                                              : Theme.paddingMedium
    property real _headerHeight: Screen.sizeCategory >= Screen.Large
                                 ? Theme.itemSizeMedium
                                 : Theme.itemSizeSmall + Theme.paddingMedium
    property real _headerTopMargin: Screen.sizeCategory >= Screen.Large
                                    ? Theme.paddingLarge + Theme.paddingSmall
                                    : -((Theme.paddingMedium + Theme.paddingSmall) / 2) // first button reactive area overlapping slightly
    readonly property real _menuWidth: Screen.sizeCategory >= Screen.Large
                                       ? Theme.iconSizeLarge + Theme.paddingMedium*2 // increase icon hitbox
                                       : Theme.iconSizeMedium + Theme.paddingMedium + Theme.paddingSmall

    property bool interactive: true

    property alias shutter: shutterContainer.children
    property alias exposure: exposureMenu.children
    property alias anchorContainer: anchorContainer
    property alias container: container
    readonly property alias settingsOpacity: row.opacity

    on_CaptureButtonLocationChanged: inButtonLayout = false

    onIsPortraitChanged: {
        upperHeader.pressedMenu = null
        lowerHeader.pressedMenu = null
    }

    property list<SettingsMenuItem> _menus
    _menus: {
        var menuItems = [ ]
        if (Settings.mode.flashValues.length > 0) {
            menuItems.push(flashMenu.currentItem)
        }
        menuItems.push(whiteBalanceMenu.currentItem)
        menuItems.push(isoMenu.currentItem)
        if (Screen.sizeCategory >= Screen.Large) {
            menuItems.push(timerMenu.currentItem)
        }
        return menuItems
    }

    signal clicked(var mouse)

    function close() {
        _closing = true
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

    // Position of other elements given the capture button position
    property var _portraitPositions: [
        { "captureMode": overlayAnchorBL, "timer": overlayAnchorBR, "exposure": Text.AlignRight }, // buttonAnchorTL
        { "captureMode": overlayAnchorBL, "timer": overlayAnchorBC, "exposure": Text.AlignRight }, // buttonAnchorCL
        { "captureMode": overlayAnchorBR, "timer": overlayAnchorBC, "exposure": Text.AlignRight }, // buttonAnchorBL
        { "captureMode": overlayAnchorBL, "timer": overlayAnchorBR, "exposure": Text.AlignRight }, // buttonAnchorBC
        { "captureMode": overlayAnchorBL, "timer": overlayAnchorBC, "exposure": Text.AlignRight }, // buttonAnchorBR
        { "captureMode": overlayAnchorBL, "timer": overlayAnchorBC, "exposure": Text.AlignLeft  }, // buttonAnchorCR
        { "captureMode": overlayAnchorBL, "timer": overlayAnchorBR, "exposure": Text.AlignLeft  }, // buttonAnchorTR
    ]
    property var _landscapePositions: [
        { "captureMode": overlayAnchorBL, "timer": overlayAnchorCL, "exposure": Text.AlignRight }, // buttonAnchorTL
        { "captureMode": overlayAnchorBL, "timer": overlayAnchorTL, "exposure": Text.AlignRight }, // buttonAnchorCL
        { "captureMode": overlayAnchorCL, "timer": overlayAnchorTL, "exposure": Text.AlignRight }, // buttonAnchorBL
        { "captureMode": overlayAnchorBL, "timer": overlayAnchorTL, "exposure": Text.AlignRight }, // buttonAnchorBC
        { "captureMode": overlayAnchorCR, "timer": overlayAnchorTR, "exposure": Text.AlignLeft  }, // buttonAnchorBR
        { "captureMode": overlayAnchorBR, "timer": overlayAnchorTR, "exposure": Text.AlignLeft  }, // buttonAnchorCR
        { "captureMode": overlayAnchorBR, "timer": overlayAnchorCR, "exposure": Text.AlignLeft  }, // buttonAnchorTR
    ]

    Item {
        id: shutterContainer

        parent: overlay._buttonAnchors[overlay._captureButtonLocation]
        anchors.fill: parent
        enabled: !overlay.open && !overlay.inButtonLayout
    }

    Item {
        parent: overlay
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: Theme.paddingLarge
        }

        width: Theme.itemSizeMedium
        height: Theme.itemSizeMedium
        opacity: !Settings.defaultSettings ? row.opacity : 0.0
        visible: overlay.expanded
        z: 1

        Behavior on opacity {
            enabled: overlay.expanded
            FadeAnimation {}
        }

        CameraButton {
            background.visible: false
            enabled: !Settings.defaultSettings && parent.opacity > 0.0

            icon {
                opacity: pressed ? 0.5 : 1.0
                source: "image://theme/icon-camera-reset?" + (pressed ? Theme.highlightColor : Theme.primaryColor)
            }

            onClicked: {
                upperHeader.pressedMenu = null
                lowerHeader.pressedMenu = null
                Settings.reset()
            }
        }
    }

    CaptureModeMenu {
        id: exposureMenu

        parent: overlay.isPortrait ? _portraitPositions[overlay._captureButtonLocation].captureMode
                                   : _landscapePositions[overlay._captureButtonLocation].captureMode
        anchors.verticalCenterOffset: Theme.paddingMedium
        alignment: parent.anchors.left !== null ? Qt.AlignRight : Qt.AlignLeft
        open: true
    }

    Item {
        parent: overlay.isPortrait ? _portraitPositions[overlay._captureButtonLocation].timer
                                   : _landscapePositions[overlay._captureButtonLocation].timer
        anchors.centerIn: parent
        width: Theme.itemSizeSmall
        height: Theme.itemSizeSmall
        opacity: Settings.mode.timer == 0 ? 0.0 : 1.0
        Behavior on opacity { FadeAnimation {} }
        Image {
            anchors.centerIn: parent
            source: "image://theme/icon-m-timer"
        }
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
                if (overlay.expanded) {
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
                height: overlay.topButtonRowHeight

                gradient: Gradient {
                    GradientStop { position: 0.0; color: Theme.rgba("black", 0.7) }
                    GradientStop { position: 1.0; color: "transparent" }
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

            OverlayAnchor { id: overlayAnchorBL; anchors { left: parent.left; bottom: parent.bottom } }
            OverlayAnchor { id: overlayAnchorBC; anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom } }
            OverlayAnchor { id: overlayAnchorBR; anchors { right: parent.right; bottom: parent.bottom } }
            OverlayAnchor { id: overlayAnchorCL; anchors { left: parent.left; verticalCenter: parent.verticalCenter } }
            OverlayAnchor { id: overlayAnchorCR; anchors { right: parent.right; verticalCenter: parent.verticalCenter } }
            OverlayAnchor { id: overlayAnchorTL; anchors { left: parent.left; top: parent.top; leftMargin: Theme.paddingLarge } }
            OverlayAnchor { id: overlayAnchorTR; anchors { right: parent.right; top: parent.top; rightMargin: Theme.paddingLarge } }
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

            y: Math.round(height * panel.y / panel.height) + overlay._headerHeight + overlay._headerTopMargin
            anchors {
                horizontalCenter: parent.horizontalCenter
                horizontalCenterOffset: overlay.isPortrait ? 0 : -width/2
            }

            height: Screen.height / 2

            opacity: 1 - container.opacity
            enabled: overlay.expanded
            visible: overlay.expanded

            spacing: overlay._menuItemHorizontalSpacing

            SettingsMenu {
                id: flashMenu

                visible: model.length > 0
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
                id: isoMenu

                width: overlay._menuWidth
                title: Settings.isoText
                header: upperHeader
                model: Settings.mode.isoValues
                delegate: SettingsMenuItem {
                    settings: Settings.mode
                    property: "iso"
                    value: modelData
                    icon: Settings.isoIcon(modelData)
                    iconVisible: !selected
                }
            }
        }

        Row {
            id: rightRow // bottom right or single row right side
            anchors {
                top: overlay.isPortrait ? lowerHeader.bottom : row.top
                left: overlay.isPortrait ? row.left : row.right
                leftMargin: overlay.isPortrait ? 0 : overlay._menuItemHorizontalSpacing
            }

            opacity: row.opacity
            visible: overlay.expanded

            spacing: overlay._menuItemHorizontalSpacing

            SettingsMenu {
                id: cameraDeviceMenu

                width: overlay._menuWidth
                title: Settings.cameraText
                header: overlay.isPortrait ? lowerHeader : upperHeader
                model: [ "primary", "secondary" ]
                delegate: SettingsMenuItem {
                    settings: Settings
                    property: "cameraDevice"
                    value: modelData
                    icon: Settings.cameraIcon(modelData)
                }
            }

            SettingsMenu {
                id: timerMenu

                parent: Screen.sizeCategory >= Screen.Large ? row : rightRow

                width: overlay._menuWidth
                title: Settings.timerText
                header: Screen.sizeCategory < Screen.Large && overlay.isPortrait ? lowerHeader : upperHeader
                model: Settings.mode.timerValues
                delegate: SettingsMenuItem {
                    settings: Settings.mode
                    property: "timer"
                    value: modelData
                    icon: Settings.timerIcon(modelData)
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

        HeaderLabel {
            id: upperHeader

            anchors { left: parent.left; bottom: row.top; right: parent.right }
            height: overlay._headerHeight
            opacity: row.opacity
        }

        HeaderLabel {
            id: lowerHeader

            anchors { left: parent.left; bottom: row.bottom; right: parent.right }
            height: overlay._headerHeight
            opacity: row.opacity
        }
    }

    Row {
        id: topRow

        property real _topRowMargin: overlay.topButtonRowHeight/2 - overlay._menuWidth/2

        anchors {
            horizontalCenter: parent.horizontalCenter
            horizontalCenterOffset: overlay.isPortrait ? 0 : -width/2
        }
        spacing: row.spacing

        Repeater {
            model: overlay._menus
            delegate: Item {
                id: statusItem

                y: model.y != undefined
                        ? Math.max(topRow._topRowMargin, row.y + model.y)
                        : topRow._topRowMargin

                width: overlay._menuWidth
                height: width

                Image {
                    anchors.centerIn: parent
                    source: model.icon != undefined ? model.icon : ""
                    smooth: true
                }
            }
        }
    }

    ExposureSlider {
        id: exposureSlider
        alignment: overlay.isPortrait ? _portraitPositions[overlay._captureButtonLocation].exposure
                                      : _landscapePositions[overlay._captureButtonLocation].exposure
        x: alignment == Text.AlignLeft ? (isPortrait ? 0 : Theme.paddingLarge)
                                       : parent.width - width - (isPortrait ? 0 : Theme.paddingLarge)
        anchors.verticalCenter: parent.verticalCenter
        enabled: !overlay.open && !overlay.inButtonLayout
        opacity: 1.0 - settingsOpacity
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
