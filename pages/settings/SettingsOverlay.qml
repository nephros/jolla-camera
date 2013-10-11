import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0

Item {
    id: overlay

    property Camera camera
    property bool isPortrait
    property bool open
    property bool inButtonLayout
    readonly property bool expanded: open || _closing || verticalAnimation.running || dragArea.drag.active
    default property alias _data: container.data

    property alias portraitAnchor: portraitAnchor
    readonly property Item landscapeAnchor: container.children[Settings.global.captureButtonLocation + 1]

    property real _lastPos
    property real _direction

    property real _progress: (panel.y + panel.height) / panel.height
    property bool _closing

    property bool interactive: true

    readonly property int _captureButtonLocation: Settings.global.captureButtonLocation
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
            opacity: 1 - overlay._progress

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
                id: layoutHighlight

                width: overlay.width
                height: overlay.height

                z: 1

                color: Theme.highlightDimmerColor
                visible: overlay.inButtonLayout || layoutAnimation.running
                opacity: overlay.inButtonLayout ? 0.6 : 0.0
                Behavior on opacity { FadeAnimation { id: layoutAnimation } }

                Label {
                    anchors {
                        centerIn: parent
                        verticalCenterOffset: -Theme.paddingLarge
                    }
                    width: Screen.width - Theme.itemSizeExtraLarge
                    font.pixelSize: Theme.fontSizeExtraLarge
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap

                    //% "Select location for the landscape capture key"
                    text: qsTrId("camera-la-capture-key-location")

                }
            }

            ButtonAnchor { index: 0; anchors { left: parent.left; top: parent.top } }
            ButtonAnchor { index: 1; anchors { left: parent.left; verticalCenter: parent.verticalCenter } }
            ButtonAnchor { index: 2; anchors { left: parent.left; bottom: parent.bottom } }
            ButtonAnchor { id: portraitAnchor; index: 3; anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom } }
            ButtonAnchor { index: 4; anchors { right: parent.right; bottom: parent.bottom } }
            ButtonAnchor { index: 5; anchors { right: parent.right; verticalCenter: parent.verticalCenter } }
            ButtonAnchor { index: 6; anchors { right: parent.right; top: parent.top } }
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
            height: Screen.width
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

            y: Theme.paddingSmall + height * panel.y / panel.height
            anchors.horizontalCenter: parent.horizontalCenter

            height: overlay.height - Theme.paddingSmall
            spacing: Theme.paddingMedium

            opacity: 1 - container.opacity

            enabled: overlay.expanded

            SettingsMenu {
                id: captureModeMenu

                //% "Camera Mode"
                title: qsTrId("camera-la-capture-mode")
                model: [ Camera.CaptureStillImage, Camera.CaptureVideo ]
                delegate: SettingsMenuItem {
                    property: "captureMode"
                    settings: Settings
                    value: modelData
                    icon: Settings.captureModeIcon(modelData)
                }
            }
            SettingsMenu {
                id: flashMenu

                title: Settings.flashText(Settings.mode.flash)
                model: [ Camera.FlashOn, Camera.FlashOff, Camera.FlashAuto ]
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
                model: [
                    CameraImageProcessing.WhiteBalanceSunlight,
                    CameraImageProcessing.WhiteBalanceCloudy,
                    CameraImageProcessing.WhiteBalanceAuto,
                    CameraImageProcessing.WhiteBalanceTungsten,
                    CameraImageProcessing.WhiteBalanceFluorescent
                ]
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
                model: [
                    Camera.FocusContinuous,
                    Camera.FocusInfinity,
                    Camera.FocusMacro,
                    Camera.FocusAuto
                ]
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
                margins: (Screen.width - row.width) / 2
            }

            Label {
                width: Theme.itemSizeMedium
                height: Theme.itemSizeExtraSmall

                color: Theme.highlightColor
                font.capitalization: Font.AllUppercase
                font.pixelSize: Theme.fontSizeTiny
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter

                text: Settings.global.shootingMode == "main-camera"
                        //% "Main camera"
                        ? qsTrId("camera-la-main-camera")
                        //% "Front camera"
                        : qsTrId("camera-la-front-camera")
            }

            Item {
                width: Theme.itemSizeMedium
                height: Theme.itemSizeSmall

                Image {
                    width: Theme.iconSizeSmall
                    height: Theme.iconSizeSmall

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
                Settings.global.shootingMode = Settings.global.shootingMode == "main-camera"
                        ? "front-camera"
                        : "main-camera"
            }
        }
    }

    MouseArea {
        anchors.horizontalCenter: parent.horizontalCenter
        width: row.width
        height: Theme.itemSizeLarge
        enabled: !overlay.expanded

        onClicked: overlay.open = true
    }

    Row {
        spacing: Theme.paddingMedium

        anchors.horizontalCenter: parent.horizontalCenter

        Repeater {
            model: overlay._menus
            delegate: Item {
                id: statusItem

                y: model.y != undefined
                        ? Math.max(0, row.y + model.y)
                        : 0

                width: Theme.itemSizeLarge
                height: Theme.itemSizeSmall

                Image {
                    width: Theme.iconSizeSmall
                    height: Theme.iconSizeSmall

                    anchors.centerIn: parent
                    source: model.icon != undefined
                            ? model.icon + "?" + Theme.highlightColor
                            : ""
                    smooth: true
                }
            }
        }
    }
}
