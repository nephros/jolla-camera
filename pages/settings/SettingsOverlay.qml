import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
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

    readonly property int timerAlignment: timerContainer.parent == timerAnchorBL
                ? Qt.AlignLeft
                : Qt.AlignRight

    property real _lastPos
    property real _direction

    property real _progress: (panel.y + panel.height) / panel.height
    property bool _closing

    property real _menuItemHorizontalSpacing: Screen.sizeCategory >= Screen.Large
                                              ? Theme.paddingLarge * 2
                                              : Theme.paddingLarge + Theme.paddingSmall
    property real _menuItemVerticalSpacing: Screen.sizeCategory >= Screen.Large
                                            ? 0
                                            : Theme.paddingMedium + Theme.paddingSmall
    property real _headerHeight: Screen.sizeCategory >= Screen.Large
                                 ? Theme.itemSizeMedium
                                 : Theme.itemSizeSmall + Theme.paddingMedium
    property real _headerTopMargin: Screen.sizeCategory >= Screen.Large
                                    ? Theme.paddingLarge + Theme.paddingSmall
                                    : 0

    property bool interactive: true

    property alias shutter: shutterContainer.children
    property alias timer: timerContainer.children
    property alias exposure: exposureMenu.children
    property alias anchorContainer: anchorContainer
    property alias container: container
    readonly property alias settingsOpacity: row.opacity

    readonly property int exposureAlignment: shutterContainer.parent == timerAnchorBR
                ? Qt.AlignRight
                : Qt.AlignLeft

    readonly property real _menuWidth: Screen.sizeCategory >= Screen.Large
                                       ? Theme.iconSizeLarge + Theme.paddingMedium*2 // increase icon hitbox
                                       : Theme.iconSizeMedium

    on_CaptureButtonLocationChanged: inButtonLayout = false

    onIsPortraitChanged: {
        upperHeader.pressedMenu = null
        lowerHeader.pressedMenu = null
    }

    property list<SettingsMenuItem> _menus
    _menus: {
        var menuItems = [ captureModeMenu.currentItem ]
        if (Screen.sizeCategory >= Screen.Large) {
            menuItems.push(isoMenu.currentItem)
        }
        if (Settings.mode.flashValues.length > 0) {
            menuItems.push(flashMenu.currentItem)
        }
        menuItems.push(whiteBalanceMenu.currentItem)
        menuItems.push(focusMenu.currentItem)
        if (Screen.sizeCategory >= Screen.Large) {
            menuItems.push(timerMenu.currentItem)
        }
        return menuItems
    }

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

    ButtonAnchor {
        id: resetButton
        parent: overlay
        anchors {
            right: parent.right
            bottom: parent.bottom
        }

        opacity: !Settings.defaultSettings ? row.opacity : 0.0
        visible: overlay.expanded

        Behavior on opacity {
            enabled: overlay.expanded
            FadeAnimation {}
        }

        CameraButton {
            background.visible: false
            enabled: !Settings.defaultSettings

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

        Row {
            id: row

            y: Math.round(height * panel.y / panel.height) + overlay._headerHeight + overlay._headerTopMargin
            anchors.horizontalCenter: parent.horizontalCenter
            height: Screen.height / 2

            opacity: 1 - container.opacity
            enabled: overlay.expanded
            visible: overlay.expanded

            spacing: overlay._menuItemHorizontalSpacing

            SettingsMenu {
                id: captureModeMenu

                width: overlay._menuWidth
                title: Settings.captureModeText
                spacing: overlay._menuItemVerticalSpacing
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

            Item {
                id: isoMenuTabletLayoutParent

                width: childrenRect.width
                height: childrenRect.height
            }

            SettingsMenu {
                id: flashMenu

                visible: model.length > 0
                width: overlay._menuWidth
                title: Settings.flashText
                spacing: overlay._menuItemVerticalSpacing
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
                spacing: overlay._menuItemVerticalSpacing
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
                spacing: overlay._menuItemVerticalSpacing
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

        Row {
            id: leftRow
            anchors {
                top: overlay.isPortrait ? lowerHeader.bottom : row.top
                right: overlay.isPortrait ? row.horizontalCenter : row.left
                rightMargin: overlay.isPortrait ? overlay._menuItemHorizontalSpacing/2 : overlay._menuItemHorizontalSpacing
            }

            opacity: row.opacity
            visible: overlay.expanded

            spacing: overlay._menuItemHorizontalSpacing

            SettingsMenu {
                id: cameraDeviceMenu

                width: overlay._menuWidth
                title: Settings.cameraText
                spacing: overlay._menuItemVerticalSpacing
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
                id: isoMenu

                parent: Screen.sizeCategory >= Screen.Large ? isoMenuTabletLayoutParent : leftRow

                width: overlay._menuWidth
                title: Settings.isoText
                spacing: overlay._menuItemVerticalSpacing
                header: Screen.sizeCategory < Screen.Large && overlay.isPortrait ? lowerHeader : upperHeader
                model: Settings.mode.isoValues
                delegate: SettingsMenuItem {
                    settings: Settings.mode
                    property: "iso"
                    value: modelData
                    icon: Settings.isoIcon(modelData)
                }
            }
        }

        Row {
            id: rightRow
            anchors {
                top: leftRow.top
                left: overlay.isPortrait ? row.horizontalCenter : row.right
                leftMargin: overlay.isPortrait ? overlay._menuItemHorizontalSpacing/2 : overlay._menuItemHorizontalSpacing
            }

            opacity: row.opacity
            visible: overlay.expanded

            spacing: overlay._menuItemHorizontalSpacing

            SettingsMenu {
                id: timerMenu

                parent: Screen.sizeCategory >= Screen.Large ? row : rightRow

                width: overlay._menuWidth
                title: Settings.timerText
                spacing: overlay._menuItemVerticalSpacing
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
                spacing: overlay._menuItemVerticalSpacing
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

        anchors.horizontalCenter: parent.horizontalCenter
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
