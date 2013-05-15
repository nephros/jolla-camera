import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0
import "../settings"
import "../views"

SplitItem {
    id: captureView

    property bool active
    property bool windowActive
    property int orientation
    property int effectiveIso: modeSettings.iso

    property bool menuOpen: captureView.contracted
            || shootingModeOverlay.expanded
            || settingsCompass.expanded
            || captureCompass.expanded

    property bool _complete

    dock: orientation == Orientation.Portrait ? Dock.Bottom : Dock.Right

    onEffectiveIsoChanged: {
        if (effectiveIso == 0) {
            camera.exposure.setAutoIsoSensitivity()
        } else {
            camera.exposure.manualIso = modeSettings.iso
        }
    }

    Component.onCompleted: _complete = true

    Camera {
        id: camera

        property alias locks: cameraLocks

        captureMode: Camera.CaptureStillImage
        cameraState: captureView._complete && captureView.windowActive
                    ? (captureView.active ? Camera.ActiveState : Camera.LoadedState)
                    : Camera.UnloadedState

        imageCapture.resolution: settings.defaultImageResolution(globalSettings.aspectRatio)
        videoRecorder{
            resolution: settings.defaultVideoResolution(globalSettings.aspectRatio)
            frameRate: 15
        }
        focus {
            focusMode: captureMode == Camera.CaptureStillImage
                    ? modeSettings.focusDistance
                    : modeSettings.videoFocus
            focusPointMode: modeSettings.focusDistanceConfigurable
                    ? Camera.FocusPointCustom
                    : Camera.FocusPointAuto
        }
        flash.flashMode: modeSettings.flash
        imageProcessing.whiteBalanceMode: modeSettings.whiteBalance

        exposure {
            exposureMode: modeSettings.exposureMode
            exposureCompensation: modeSettings.exposureCompensation / 2.0
            meteringMode: modeSettings.meteringMode
        }
    }

    CameraLocks {
        id: cameraLocks
        camera: camera
    }

    VideoOutput {
        x: -parent.x / 2
        y: -parent.y / 2
        width: page.width
        height: page.height

        source: camera
        fillMode: VideoOutput.PreserveAspectFit
    }

    ShootingModeOverlay {
        id: shootingModeOverlay

        camera: camera

        x: -parent.x / 2
        y: -parent.y / 2
        width: page.width
        height: page.height

        interactive: !settingsCompass.expanded && !captureCompass.expanded && !captureView.contracted
        orientation: captureView.orientation
        opacity: 1 - positioner.opacity

        MouseArea {
            anchors.fill: parent

            onClicked: {
                if (shootingModeOverlay.interactive || shootingModeOverlay.open) {
                    if (modeSettings.focusDistanceConfigurable) {
                        var focusX = mouse.x / width
                        var focusY = mouse.y / height

                        if (captureView.orientation == Orientation.Portrait)  {
                            var temp = focusX
                            focusX = focusY
                            focusY = temp
                        }
                        if (globalSettings.aspectRatio == Settings.AspectRatio_4_3) {
                            // Scale the click point from the screen 16:9 to the 4:3 window.
                            // (3 * 16) / (4 * 9) == 4/3
                            // (4/3 - 1) / 2 == 1/6
                            focusX = (focusX * 4 / 3) - (1 / 6)
                        }
                        if (focusX >= 0 && focusX <= 1) {
                            camera.focus.customFocusPoint = Qt.point(focusX, focusY)
                        }
                    }
                } else {
                    captureView.split = false
                    shootingModeOverlay.open = false
                    settingsCompass.closeMenu()
                    captureCompass.closeMenu()
                }
            }
        }

        Item {
            id: compassAnchor
            anchors {
                fill: parent
                leftMargin: settingsCompass.width / 2
                rightMargin: settingsCompass.width / 2
            }
        }

        SettingsCompass {
            id: settingsCompass

            camera: camera
            enabled: !shootingModeOverlay.expanded
            centerMenu: captureView.orientation == Orientation.Landscape
            verticalAlignment: captureView.orientation == Orientation.Landscape
                        ? globalSettings.settingsVerticalAlignment
                        : Qt.AlignBottom
            topMargin: theme.iconSizeLarge + (theme.paddingLarge * 2)
            bottomMargin: 112
            anchors {
                horizontalCenter: !globalSettings.reverseButtons
                            ? compassAnchor.left
                            : compassAnchor.right
                top: parent.top
                bottom: parent.bottom
            }

            onClicked: if (interactive) { captureView.split = true }
            onPressAndHold: if (interactive) { positioner.enabled = true }
        }

        Rectangle {
            id: focusLock

            width: 180
            height: 180

            anchors.centerIn: parent

            border.width: 3
            border.color: theme.highlightBackgroundColor
            color: "#00000000"

            opacity: cameraLocks.focusStatus == CameraLocks.Locked ? 1 : 0
            Behavior on opacity { FadeAnimation {} }
        }

        Rectangle {
            width: 24
            height: 24

            radius: 2
            anchors.centerIn: parent
            color: theme.highlightBackgroundColor

            opacity: modeSettings.meteringMode == Camera.MeteringSpot ? 1 : 0
            Behavior on opacity { FadeAnimation {} }
        }

        CaptureCompass {
            id: captureCompass

            camera: camera

            enabled: !shootingModeOverlay.expanded
            centerMenu: captureView.orientation == Orientation.Landscape
            verticalAlignment: captureView.orientation == Orientation.Landscape
                        ? globalSettings.captureVerticalAlignment
                        : Qt.AlignBottom
            topMargin: settingsCompass.topMargin
            bottomMargin: settingsCompass.bottomMargin
            anchors {
                horizontalCenter: !globalSettings.reverseButtons
                            ? compassAnchor.right
                            : compassAnchor.left
                top: parent.top
                bottom: parent.bottom
            }


            onPressAndHold: if (interactive) { positioner.enabled = true }
        }
    }

    CompassPositioner {
        id: positioner

        width: captureView.width
        height: captureView.height
        topMargin: captureView.orientation == Orientation.Portrait
                    ? captureView.height - settingsCompass.width - settingsCompass.bottomMargin
                    : settingsCompass.topMargin
        bottomMargin: settingsCompass.bottomMargin

        enabled: false
        visible: enabled || animating || positionerOpacity.running
        opacity: enabled || animating ? 1 : 0
        Behavior on opacity { FadeAnimation { id: positionerOpacity } }
    }

    background: [
        Loader {
//            asynchronous: true

            SettingsMenu {
                width: captureView.backgroundItem.width
                height: captureView.backgroundItem.height

                camera: camera
            }
        }

    ]
}
