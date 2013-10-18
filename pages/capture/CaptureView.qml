import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0
import org.nemomobile.time 1.0
import org.nemomobile.policy 1.0
import org.nemomobile.ngf 1.0
import "../settings"

Item {
    id: captureView

    property bool active
    property bool windowActive
    property int orientation
    property int effectiveIso: Settings.mode.iso
    property alias inButtonLayout: settingsOverlay.inButtonLayout

    property alias camera: camera
    property QtObject viewfinder

    property bool _complete
    property int _unload

    property bool _touchFocus

    property real _shutterOffset

    readonly property bool isPortrait: orientation == Orientation.Portrait
                || orientation == Orientation.PortraitInverted
    readonly property bool effectiveActive: windowActive && active

    readonly property bool _canCapture: (camera.captureMode == Camera.CaptureStillImage && camera.imageCapture.ready)
                || (camera.captureMode == Camera.CaptureVideo && camera.videoRecorder.recorderStatus >= CameraRecorder.LoadedStatus)

    readonly property int _stillFocus: !_touchFocus || Settings.mode.focusDistance != Camera.FocusContinuous
                ? Settings.mode.focusDistance
                : Camera.FocusAuto

    property var _startTime: new Date()
    property var _endTime: _startTime

    signal recordingStopped(url url, string mimeType)
    signal loaded

    onEffectiveIsoChanged: {
        if (effectiveIso == 0) {
            camera.exposure.setAutoIsoSensitivity()
        } else {
            camera.exposure.manualIso = Settings.mode.iso
        }
    }

    onEffectiveActiveChanged: {
        if (!effectiveActive) {
            settingsOverlay.open = false
            settingsOverlay.inButtonLayout = false
        }
    }

    on_CanCaptureChanged: {
        if (!_canCapture) {
            startRecordTimer.running = false
        }
    }

    Component.onCompleted: _complete = true

    Timer {
        id: reloadTimer
        interval: 10
        running: captureView._unload && camera.cameraStatus == Camera.UnloadedStatus
        onTriggered: {
            captureView._unload = false
        }
    }

    NonGraphicalFeedback {
        id: shutterEvent
        event: "camera_shutter"
    }

    NonGraphicalFeedback {
        id: recordStartEvent
        event: "video_record_start"
    }

    Timer {
        id: startRecordTimer

        interval: 200
        onTriggered: {
            camera.videoRecorder.record()
            if (camera.videoRecorder.recorderState == CameraRecorder.RecordingState) {
                camera.videoRecorder.recorderStateChanged.connect(camera._finishRecording)
                extensions.disableNotifications(captureView, true)
            }
        }
    }

    NonGraphicalFeedback {
        id: recordStopEvent
        event: "video_record_stop"
    }

    Camera {
        id: camera

        property alias locks: cameraLocks
        property alias extensions: extensions

        function autoFocus() {
            if (camera.captureMode == Camera.CaptureStillImage
                        && cameraLocks.focusStatus == Camera.Unlocked) {
                cameraLocks.lockFocus()
            }
        }

        function captureImage() {
            shutterEvent.play()
            camera.imageCapture.captureToLocation(Settings.photoCapturePath('jpg'))
        }

        function record() {
            videoRecorder.outputLocation = Settings.videoCapturePath("mp4")
            startRecordTimer.running = true
            recordStartEvent.play()
        }

        function _finishRecording() {
            if (videoRecorder.recorderState == CameraRecorder.StoppedState) {
                videoRecorder.recorderStateChanged.disconnect(_finishRecording)
                extensions.disableNotifications(captureView, false)
                var finalUrl = Settings.completeCapture(videoRecorder.outputLocation)
                if (finalUrl != "") {
                    captureView.recordingStopped(finalUrl, videoRecorder.mediaContainer)
                }
                recordStopEvent.play()
            }
        }

        captureMode: Settings.captureMode
        cameraState: captureView._complete && captureView.effectiveActive && !captureView._unload
                    ? Camera.ActiveState
                    : Camera.UnloadedState

        onCameraStateChanged: {
            if (cameraState == Camera.ActiveState) {
                captureView.loaded()
            }
        }

        imageCapture {
            resolution: Settings.resolutions.image

            onImageSaved: {
                cameraLocks.unlockFocus()

                captureAnimation.start()
            }
            onCaptureFailed: cameraLocks.unlockFocus()
        }
        videoRecorder{
            resolution: Settings.resolutions.video
            frameRate: 30
            audioChannels: 2
            audioSampleRate: Settings.global.audioSampleRate
            audioCodec: Settings.global.audioCodec
            videoCodec: Settings.global.videoCodec
            mediaContainer: Settings.global.mediaContainer
        }
        focus {
            focusMode: captureMode == Camera.CaptureStillImage
                    ? captureView._stillFocus
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
            if (focusStatus == Camera.Unlocked) {
                captureView._touchFocus = false
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

    SettingsOverlay {
        id: settingsOverlay

        width: captureView.width
        height: captureView.height

        isPortrait: captureView.isPortrait

        onClicked: {
            captureView._touchFocus = true
            cameraLocks.lockFocus()
        }

        Item {
            id: captureAnchor
            anchors {
                fill: parent
                margins: Theme.paddingLarge + (Theme.itemSizeExtraLarge / 2)
            }
        }

        MouseArea {
            id: captureButton

            width: Theme.itemSizeExtraLarge
            height: Theme.itemSizeExtraLarge

            z: settingsOverlay.inButtonLayout ? 1 : 0

            enabled: !settingsOverlay.inButtonLayout && captureView._canCapture

            anchors.centerIn: captureView.isPortrait
                    ? settingsOverlay.portraitAnchor
                    : settingsOverlay.landscapeAnchor

            onPressed: {
                camera.autoFocus()
            }

            onClicked: {
                if (camera.captureMode == Camera.CaptureStillImage) {
                    camera.captureImage()
                } else if (startRecordTimer.running) {
                    startRecordTimer.running = false
                } else if (camera.videoRecorder.recorderState == CameraRecorder.RecordingState) {
                    camera.videoRecorder.stop()
                } else {
                    camera.record()
                }
            }

            Rectangle {
                radius: Theme.itemSizeMedium / 2
                width: Theme.itemSizeMedium
                height: Theme.itemSizeMedium

                anchors.centerIn: parent

                opacity: 0.6
                color: Theme.highlightDimmerColor
            }

            Image {
                width: Theme.iconSizeMedium
                height: Theme.iconSizeMedium

                anchors.centerIn: parent

                opacity: captureButton.pressed ? 0.5 : 1.0

                source: startRecordTimer.running || camera.videoRecorder.recorderState == CameraRecorder.RecordingState
                        ? "image://theme/icon-camera-stop?" + Theme.highlightColor
                        : "image://theme/icon-camera-shutter-release?" + (captureView._canCapture
                                ? Theme.highlightColor
                                : Theme.highlightDimmerColor)
            }
        }

        Item {
            id: focusArea

            width: Screen.width
                   * extensions.viewfinderResolution.width
                   / extensions.viewfinderResolution.height
            height: Screen.width

            rotation: -extensions.orientation
            anchors.centerIn: parent

            visible: camera.captureMode == Camera.CaptureStillImage

            Repeater {
                model: camera.focus.focusZones
                delegate: Item {
                    x: focusArea.width * area.x
                    y: focusArea.height * area.y
                    width: focusArea.width * area.width
                    height: focusArea.height * area.height

                    visible: status != Camera.FocusAreaUnused
                    opacity: status == Camera.FocusAreaFocused ? 1.0 : 0.3
                    Behavior on opacity { FadeAnimation {} }

                    Rectangle {
                        width: Math.min(parent.width, parent.height)
                        height: width

                        anchors.centerIn: parent
                        border.width: 3
                        border.color: Theme.primaryColor
                        color: "#00000000"
                    }
                }
            }
        }

        Rectangle {
            width: 24
            height: 24

            radius: 2
            anchors.centerIn: parent
            color: Theme.primaryColor

            visible: camera.captureMode == Camera.CaptureStillImage
            opacity: Settings.mode.meteringMode == Camera.MeteringSpot ? 1 : 0
            Behavior on opacity { FadeAnimation {} }
        }

        Label {
            anchors.centerIn: parent
            text: Format.formatDuration(
                      ((clock.enabled ? clock.time : captureView._endTime) - captureView._startTime) / 1000,
                      Formatter.DurationLong)
            font.pixelSize: Theme.fontSizeExtraSmall
            opacity: camera.captureMode == Camera.CaptureVideo ? 1 : 0
            Behavior on  opacity { FadeAnimation {} }
        }

        WallClock {
            id: clock
            updateFrequency: WallClock.Second
            enabled: camera.videoRecorder.recorderState == CameraRecorder.RecordingState
            onEnabledChanged: {
                if (enabled) {
                    captureView._startTime = clock.time
                    captureView._endTime = captureView._startTime
                } else {
                    captureView._endTime = captureView._startTime
                }
            }
        }
    }

    MediaKey {
        enabled: keysResource.acquired && camera.captureMode == Camera.CaptureStillImage
        key: Qt.Key_VolumeUp
        onPressed: camera.autoFocus()
        onReleased: camera.captureImage()
    }
    MediaKey {
        enabled: keysResource.acquired && camera.captureMode == Camera.CaptureStillImage
        key: Qt.Key_VolumeDown
        onPressed: camera.autoFocus()
        onReleased: camera.captureImage()
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
