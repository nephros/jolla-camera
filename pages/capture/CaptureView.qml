import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0
import org.nemomobile.policy 1.0
import "../settings"

Item {
    id: captureView

    property bool active
    property bool windowActive
    property int orientation
    property int effectiveIso: Settings.mode.iso

    property alias camera: camera
    property QtObject viewfinder

    property bool _complete
    property int _unload
    property int _aspectRatio

    property real _shutterOffset

    property bool _capturing

    readonly property bool isPortrait: orientation == Orientation.Portrait
                || orientation == Orientation.PortraitInverted

    signal recordingStopped(url url, string mimeType)

    onEffectiveIsoChanged: {
        if (effectiveIso == 0) {
            camera.exposure.setAutoIsoSensitivity()
        } else {
            camera.exposure.manualIso = Settings.mode.iso
        }
    }

    onActiveChanged: {
        if (!active) {
            shootingModeOverlay.open = false
            settingsCompass.closeMenu()
            captureCompass.closeMenu()
            positioner.enabled = false
        }
    }

    Component.onCompleted: {
        extensions.face = Settings.mode.face
        _aspectRatio = Settings.global.aspectRatio
        _complete = true
    }


    function reloadOnSettingsChanged() {
        if (_aspectRatio != Settings.global.aspectRatio) {
            _aspectRatio = Settings.global.aspectRatio
            _unload = true
        }
    }

    function _autoFocus() {
        if (Settings.mode.focusDistanceConfigurable) {
            if (cameraLocks.focusStatus == Camera.Unlocked) {
                cameraLocks.lockFocus()
            } else if (!captureView._capturing) {
                cameraLocks.unlockFocus()
            }
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
            if (!captureView._capturing
                    && cameraLocks.focusStatus == Camera.Unlocked
                    && camera.focus.focusMode == Camera.FocusAuto) {
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
                captureView._capturing = false
                cameraLocks.unlockFocus()

                captureAnimation.start()
            }
            onCaptureFailed: {
                captureView._capturing = false
                cameraLocks.unlockFocus()
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
                    : Settings.global.videoFocus
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
            if (focusStatus != Camera.Searching && captureView._capturing) {
                camera.captureImage()
            }
        }
     }

    CameraExtensions {
        id: extensions
        camera: camera

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

        viewfinderResolution: Settings.resolutions.viewfinder

        onFaceChanged: {
            if (captureView._complete) {
                // Force the camera to reload when the selected face changes.
                captureView._unload = true;
            }
        }
    }

    Binding {
        target: captureView.viewfinder
        property: "x"
        value: captureView.isPortrait
               ? captureView.parent.x + captureView.x + captureView._shutterOffset
               : 0
    }

    Binding {
        target: captureView.viewfinder
        property: "y"
        value: !captureView.isPortrait
                ? captureView.parent.x + captureView.x + captureView._shutterOffset
                : 0
    }

    Binding {
        target: captureView.viewfinder
        property: "source"
        value: camera
    }


    Binding {
        target: captureView.viewfinder
        property: "mirror"
        value: extensions.face == CameraExtensions.Front
    }

    SequentialAnimation {
        id: captureAnimation

        NumberAnimation {
            target: captureView
            property: "_shutterOffset"
            from: 0
            to: captureView.isPortrait ? -captureView.height : -captureView.width
            duration: 200
        }

        PropertyAction {
            target: viewfinder
            property: "opacity"
            value: 0
        }

        PropertyAction {
            target: captureView
            property: "_shutterOffset"
            value: 0
        }
        FadeAnimation {
            target: viewfinder
            from: 0
            to: 1
        }
    }

    ShootingModeOverlay {
        id: shootingModeOverlay

        camera: camera

        width: captureView.width
        height: captureView.height

        interactive: !settingsCompass.expanded && !captureCompass.expanded
        isPortrait: captureView.isPortrait
        opacity: 1 - positioner.opacity

        onExpandedChanged: {
            if (!expanded) {
                extensions.face = Settings.mode.face
            }
        }

        onClicked: {
            if (shootingModeOverlay.interactive && !shootingModeOverlay.expanded) {
                captureView._autoFocus()
            } else {
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

            opacity: cameraLocks.focusStatus != Camera.Unlocked
                     ? (cameraLocks.focusStatus == Camera.Locked && !captureView._capturing ? 1.0 : 0.3)
                     : 0
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
        onPressed: captureView._autoFocus()
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
}
