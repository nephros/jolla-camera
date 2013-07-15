import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import "../settings"

Drawer {
    id: captureView

    property bool active
    property bool windowActive
    property int orientation
    property int effectiveIso: Settings.mode.iso

    property bool menuOpen: captureView.open
            || shootingModeOverlay.expanded
            || settingsCompass.expanded
            || captureCompass.expanded
            || positioner.enabled

    property bool _complete
    property int _unload

    dock: orientation == Orientation.Portrait ? Dock.Top : Dock.Left

    onEffectiveIsoChanged: {
        if (effectiveIso == 0) {
            camera.exposure.setAutoIsoSensitivity()
        } else {
            camera.exposure.manualIso = Settings.mode.iso
        }
    }

    Component.onCompleted: _complete = true

    Camera {
        id: camera

        property alias locks: cameraLocks

        captureMode: Camera.CaptureStillImage
        cameraState: captureView._complete && captureView.windowActive && !captureView._unload
                    ? (captureView.active ? Camera.ActiveState : Camera.LoadedState)
                    : Camera.UnloadedState

        imageCapture.resolution: Settings.defaultImageResolution(Settings.global.aspectRatio)
        videoRecorder{
            resolution: Settings.defaultVideoResolution(Settings.global.aspectRatio)
            frameRate: 15
        }
        focus {
            focusMode: captureMode == Camera.CaptureStillImage
                    ? Settings.mode.focusDistance
                    : Settings.mode.videoFocus
            focusPointMode: Settings.mode.focusDistanceConfigurable
                    ? Camera.FocusPointCustom
                    : Camera.FocusPointAuto
        }
        flash.mode: Settings.mode.flash
        imageProcessing.whiteBalanceMode: Settings.mode.whiteBalance

        exposure {
            exposureMode: Settings.mode.exposureMode
            exposureCompensation: Settings.mode.exposureCompensation / 2.0
            meteringMode: Settings.mode.meteringMode
        }
    }

    CameraLocks {
        id: cameraLocks
        camera: camera
    }

    CameraExtensions {
        id: extensions
        camera: camera
        face: Settings.mode.face

        onFaceChanged: {
            if (captureView._complete) {
                // Force the camera to reload when the selected face changes.
                captureView._unload = true;
                captureView._unload = false;
            }
        }
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

        interactive: !settingsCompass.expanded && !captureCompass.expanded && !captureView.opened
        orientation: captureView.orientation
        opacity: 1 - positioner.opacity

        onClicked: {
            if (shootingModeOverlay.interactive && !shootingModeOverlay.expanded) {
                if (Settings.mode.focusDistanceConfigurable) {
                    var focusX = mouse.x / width
                    var focusY = mouse.y / height

                    if (captureView.orientation == Orientation.Portrait)  {
                        var temp = focusX
                        focusX = focusY
                        focusY = temp
                    }
                    if (Settings.global.aspectRatio == Settings.AspectRatio_4_3) {
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
                captureView.open = false
                shootingModeOverlay.open = false
                settingsCompass.closeMenu()
                captureCompass.closeMenu()
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
            enabled: !shootingModeOverlay.expanded && !captureCompass.expanded
            centerMenu: captureView.orientation == Orientation.Landscape
            verticalAlignment: captureView.orientation == Orientation.Landscape
                        ? Settings.global.settingsVerticalAlignment
                        : Qt.AlignBottom
            topMargin: Theme.iconSizeMedium + (Theme.paddingLarge * 2)
            bottomMargin: 112
            anchors {
                horizontalCenter: !Settings.global.reverseButtons
                            ? compassAnchor.left
                            : compassAnchor.right
                top: parent.top
                bottom: parent.bottom
            }

            onClicked: if (interactive) { captureView.open = true }
            onPressAndHold: if (interactive) { positioner.enabled = true }
        }

        Rectangle {
            id: focusLock

            width: 180
            height: 180

            anchors.centerIn: parent

            border.width: 3
            border.color: Theme.highlightBackgroundColor
            color: "#00000000"

            opacity: cameraLocks.focusStatus == CameraLocks.Locked ? 1 : 0
            Behavior on opacity { FadeAnimation {} }
        }

        Rectangle {
            width: 24
            height: 24

            radius: 2
            anchors.centerIn: parent
            color: Theme.highlightBackgroundColor

            opacity: Settings.mode.meteringMode == Camera.MeteringSpot ? 1 : 0
            Behavior on opacity { FadeAnimation {} }
        }

        CaptureCompass {
            id: captureCompass

            camera: camera

            enabled: !shootingModeOverlay.expanded && !settingsCompass.expanded
            centerMenu: captureView.orientation == Orientation.Landscape
            verticalAlignment: captureView.orientation == Orientation.Landscape
                        ? Settings.global.captureVerticalAlignment
                        : Qt.AlignBottom
            topMargin: settingsCompass.topMargin
            bottomMargin: settingsCompass.bottomMargin
            anchors {
                horizontalCenter: !Settings.global.reverseButtons
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
            asynchronous: true

            SettingsMenu {
                width: captureView.backgroundItem.width
                height: captureView.backgroundItem.height

                camera: camera
            }
        }

    ]
}
