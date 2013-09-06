import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import com.jolla.camera 1.0
import org.nemomobile.policy 1.0
import "../settings"

Drawer {
    id: captureView

    property bool active
    property bool windowActive
    property int orientation
    property int effectiveIso: Settings.mode.iso

    property alias camera: camera

    property bool menuOpen: captureView.open
            || shootingModeOverlay.expanded
            || settingsCompass.expanded
            || captureCompass.expanded
            || positioner.enabled

    property bool _complete
    property int _unload
    property int _face
    property int _aspectRatio

    property bool _capturing

    readonly property bool isPortrait: orientation == Orientation.Portrait
                || orientation == Orientation.PortraitInverted

    signal recordingStopped(url url, string mimeType)

    dock: isPortrait ? Dock.Top : Dock.Left

    onEffectiveIsoChanged: {
        if (effectiveIso == 0) {
            camera.exposure.setAutoIsoSensitivity()
        } else {
            camera.exposure.manualIso = Settings.mode.iso
        }
    }

    onOpenedChanged: {
        if (!opened) {
            reloadOnSettingsChanged()
        }
    }

    Component.onCompleted: {
        _face = Settings.mode.face
        _aspectRatio = Settings.global.aspectRatio
        _complete = true
    }


    function reloadOnSettingsChanged() {
        if (_face != Settings.mode.face || _aspectRatio != Settings.global.aspectRatio) {
            _face = Settings.mode.face
            _aspectRatio = Settings.global.aspectRatio
            _unload = true
        }
    }


    Timer {
        id: reloadTimer
        interval: 10
        running: captureView._unload && camera.cameraStatus == Camera.UnloadedStatus
        onTriggered: {
            captureView._unload = false
        }
    }

    Camera {
        id: camera

        property alias locks: cameraLocks
        property alias extensions: extensions

        function captureImage() {
            if (cameraLocks.focusStatus == Camera.Unlocked && camera.focus.focusMode == Camera.FocusAuto) {
                captureView._capturing = true
                cameraLocks.lockFocus()
            } else {
                camera.imageCapture.captureToLocation(Settings.photoCapturePath('jpg'))
            }
        }

        captureMode: Camera.CaptureStillImage
        cameraState: captureView._complete && captureView.windowActive && !captureView._unload && captureView.active
                    ? Camera.ActiveState
                    : Camera.UnloadedState

        onCaptureModeChanged: captureView._capturing = false
        onCameraStateChanged: captureView._capturing = false

        imageCapture {
            resolution: Settings.resolutions.image

            onImageSaved: {
                cameraLocks.unlockFocus()
                captureView._capturing = false
            }
            onCaptureFailed: {
                cameraLocks.unlockFocus()
                captureView._capturing = false
            }
        }
        videoRecorder{
            resolution: Settings.resolutions.video
            frameRate: 30
            audioCodec: Settings.global.audioCodec
            videoCodec: Settings.global.videoCodec
            mediaContainer: Settings.global.mediaContainer
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
        onFocusStatusChanged: {
            if (focusStatus == Camera.Locked && captureView._capturing) {
                camera.captureImage()
            }
        }
     }

    CameraExtensions {
        id: extensions
        camera: camera
        face: Settings.mode.face

        rotation: {
            switch (captureView.orientation) {
            case Orientation.Portrait:
                return 0
            case Orientation.Landscape:
                return 90
            case Orientation.PortraitInverted:
                return 180
            case Orientation.LandscapeInverted:
                return 270
            }
        }

        onFaceChanged: {
            if (captureView._complete) {
                // Force the camera to reload when the selected face changes.
                captureView._unload = true;
            }
        }
    }

    Item {
        x: -parent.x / 2
        y: -parent.y / 2
        width: page.width
        height: page.height

        GStreamerVideoOutput {
            anchors.fill: parent

            source: camera
            orientation: extensions.rotation
            mirror: Settings.mode.face == CameraExtensions.Front
        }
    }

    ShootingModeOverlay {
        id: shootingModeOverlay

        camera: camera

        x: -parent.x / 2
        y: -parent.y / 2
        width: page.width
        height: page.height

        interactive: !settingsCompass.expanded && !captureCompass.expanded && !captureView.opened
        isPortrait: captureView.isPortrait
        opacity: 1 - positioner.opacity

        onExpandedChanged: {
            if (!expanded) {
                reloadOnSettingsChanged()
            }
        }

        onClicked: {
            if (shootingModeOverlay.interactive && !shootingModeOverlay.expanded) {
                if (Settings.mode.focusDistanceConfigurable) {
                    var focusX = mouse.x / width
                    var focusY = mouse.y / height

                    if (captureView.isPortrait)  {
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
            centerMenu: !captureView.isPortrait
            verticalAlignment: !captureView.isPortrait
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

            opacity: cameraLocks.focusStatus == Camera.Locked && !captureView._capturing ? 1 : 0
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
            centerMenu: !captureView.isPortrait
            verticalAlignment: !captureView.isPortrait
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
            onRecordingStopped: captureView.recordingStopped(url, mimeType)

            onPressAndHold: if (interactive) { positioner.enabled = true }
        }
    }

    CompassPositioner {
        id: positioner

        width: captureView.width
        height: captureView.height
        topMargin: captureView.isPortrait
                    ? captureView.height - settingsCompass.width - settingsCompass.bottomMargin
                    : settingsCompass.topMargin
        bottomMargin: settingsCompass.bottomMargin

        enabled: false
        visible: enabled || animating || positionerOpacity.running
        opacity: enabled || animating ? 1 : 0
        Behavior on opacity { FadeAnimation { id: positionerOpacity } }
    }

    MediaKey {
        enabled: keysResource.acquired && camera.captureMode == Camera.CaptureStillImage
        key: Qt.Key_VolumeUp
        onPressed: {
            camera.captureImage()
        }
    }
    MediaKey {
        enabled: keysResource.acquired && camera.captureMode == Camera.CaptureStillImage
        key: Qt.Key_VolumeDown
        onPressed: {
            if (cameraLocks.focusStatus == Camera.Unlocked) {
                cameraLocks.lockFocus()
            } else if (!captureView._capturing) {
                cameraLocks.unlockFocus()
            }
        }
    }

    Permissions {
        enabled: camera.captureMode == Camera.CaptureStillImage
                    && camera.cameraState == Camera.ActiveState
        autoRelease: true
        applicationClass: "camera"

        Resource {
            id: keysResource
            type: Resource.ScaleButton
            optional: true
        }
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
