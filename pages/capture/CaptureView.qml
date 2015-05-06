import QtQuick 2.0
import QtMultimedia 5.0
import QtPositioning 5.1
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import com.jolla.camera 1.0
import org.nemomobile.time 1.0
import org.nemomobile.policy 1.0
import org.nemomobile.ngf 1.0
import org.nemomobile.configuration 1.0
import "../settings"

FocusScope {
    id: captureView

    property bool active
    property bool windowVisible
    property int orientation
    property int effectiveIso: Settings.mode.iso
    property alias inButtonLayout: settingsOverlay.inButtonLayout

    property alias camera: camera
    property QtObject viewfinder

    readonly property bool recording: active
                && camera.videoRecorder.recorderState == CameraRecorder.RecordingState

    property bool _complete
    property bool _unload

    property bool _touchFocus
    property bool _captureOnFocus

    property bool _focusFailed
    property real _captureCountdown

    property real _shutterOffset
    readonly property real _viewfinderPosition: orientation == Orientation.Portrait || orientation == Orientation.Landscape
                ? parent.x + x + _shutterOffset
                : -parent.x - x - _shutterOffset

    property int _recordingDuration: ((clock.enabled ? clock.time : captureView._endTime) - captureView._startTime) / 1000

    readonly property bool isPortrait: orientation == Orientation.Portrait
                || orientation == Orientation.PortraitInverted
    readonly property bool effectiveActive: (activeFocus && active) || (windowVisible && recording)

    readonly property bool _canCapture: (camera.captureMode == Camera.CaptureStillImage && camera.imageCapture.ready)
                || (camera.captureMode == Camera.CaptureVideo && camera.videoRecorder.recorderStatus >= CameraRecorder.LoadedStatus)

    readonly property int _stillFocus: !_touchFocus || Settings.mode.focusDistance != Camera.FocusContinuous
                ? Settings.mode.focusDistance
                : Camera.FocusAuto

    readonly property bool _capturePending: _captureOnFocus
                || volumeUp.pressed
                || volumeDown.pressed
                || captureButton.pressed

    readonly property bool _mirrorViewfinder: Settings.global.cameraDevice == "secondary"

    property var _startTime: new Date()
    property var _endTime: _startTime

    signal recordingStopped(url url, string mimeType)
    signal loaded
    signal captured

    function reload() {
        if (captureView._complete) {
            captureView._unload = true;
        }
    }

    function _resetFocus() {
        focusTimer.running = false
        _touchFocus = false
        _focusFailed = false
        camera.focus.customFocusPoint = Qt.point(0.5, 0.5)
        camera.unlock()
    }

    function _writeMetaData() {
        extensions.captureTime = new Date()

        if (positionSource.active) {
            var coordinate = positionSource.position.coordinate
            if (coordinate.isValid) {
                extensions.gpsLatitude = coordinate.latitude
                extensions.gpsLongitude = coordinate.longitude
            } else {
                extensions.gpsLatitude = undefined
                extensions.gpsLongitude = undefined
            }
            extensions.gpsAltitude = positionSource.position.altitudeValid
                        ? coordinate.altitude
                        : undefined
        } else {
            extensions.gpsLatitude = undefined
            extensions.gpsLongitude = undefined
            extensions.gpsAltitude = undefined
        }
    }

    function _triggerCapture() {
        if (captureTimer.running) {
            captureView._resetFocus()
            captureTimer.running = false
        } else if (startRecordTimer.running) {
            startRecordTimer.running = false
        } else if (camera.videoRecorder.recorderState == CameraRecorder.RecordingState) {
            camera.videoRecorder.stop()
        } else if (Settings.mode.timer != 0) {
            captureTimer.restart()
        } else if (camera.captureMode == Camera.CaptureStillImage) {
            camera.captureImage()
        } else {
            camera.record()
        }
    }

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

    PositionSource {
        id: positionSource
        active: captureView.effectiveActive && Settings.locationEnabled && Settings.global.saveLocationInfo
    }

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
            captureView._writeMetaData()
            camera.videoRecorder.record()
            if (camera.videoRecorder.recorderState == CameraRecorder.RecordingState) {
                camera.videoRecorder.recorderStateChanged.connect(camera._finishRecording)
                extensions.disableNotifications(captureView, true)
            }
        }
    }

    SequentialAnimation {
        id: captureTimer

        NumberAnimation {
            id: timerAnimation
            duration: Settings.mode.timer * 1000
            from: Settings.mode.timer
            to: 0
            easing.type: Easing.Linear
            target: captureView
            property: "_captureCountdown"
        }
        ScriptAction {
            script: {
                if (camera.captureMode == Camera.CaptureStillImage) {
                     camera.captureImage()
                 } else {
                     camera.record()
                 }
            }
        }
    }

    NonGraphicalFeedback {
        id: recordStopEvent
        event: "video_record_stop"
    }

    Camera {
        id: camera

        property alias extensions: extensions

        function autoFocus() {
            settingsOverlay.close()
            if (camera.captureMode == Camera.CaptureStillImage
                    && Settings.mode.focusDistance != Camera.FocusInfinity
                    && camera.lockStatus == Camera.Unlocked) {
                camera.searchAndLock()
            }
        }

        function captureImage() {
            if (camera.lockStatus != Camera.Searching) {
                _completeCapture()
            } else {
                captureView._captureOnFocus = true
            }
        }

        function record() {
            videoRecorder.outputLocation = Settings.videoCapturePath("mp4")
            startRecordTimer.running = true
            recordStartEvent.play()
        }

        function _completeCapture() {
            captureView._writeMetaData()
            camera.imageCapture.captureToLocation(Settings.photoCapturePath('jpg'))
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

        captureMode: Settings.mode.captureMode
        cameraState: captureView._complete && captureView.effectiveActive && !captureView._unload
                    ? Camera.ActiveState
                    : Camera.UnloadedState

        onCameraStateChanged: {
            if (cameraState == Camera.ActiveState) {
                captureView.loaded()
            }
        }

        imageCapture {
            resolution: Settings.mode.imageResolution
            onResolutionChanged: reload()

            onImageSaved: {
                shutterEvent.play()
                captureView._resetFocus()

                captureAnimation.start()
            }
            onCaptureFailed: captureView._resetFocus()
        }
        videoRecorder{
            resolution: Settings.mode.videoResolution
            onResolutionChanged: reload()
            frameRate: 30
            audioChannels: 2
            audioSampleRate: Settings.global.audioSampleRate
            audioCodec: Settings.global.audioCodec
            videoCodec: Settings.global.videoCodec
            mediaContainer: Settings.global.mediaContainer
        }
        focus {
            focusMode: captureView._stillFocus
            focusPointMode: focus.focusMode != Camera.FocusAuto
                    ? Camera.FocusPointAuto
                    : Camera.FocusPointCustom
        }
        flash.mode: Settings.mode.flash
        imageProcessing.whiteBalanceMode: Settings.mode.whiteBalance

        exposure {
            exposureMode: Settings.mode.exposureMode
            exposureCompensation: Settings.mode.exposureCompensation / 2.0
            meteringMode: Settings.mode.meteringMode
        }

        onLockStatusChanged: {
           if (lockStatus == Camera.Unlocked) {
               if (camera.focus.focusMode == Camera.FocusContinuous && captureView._capturePending) {
                   captureView._touchFocus = true
                   camera.searchAndLock()
                   return
               } else if (captureView._touchFocus || captureView._capturePending) {
                   captureView._focusFailed = true
                   focusTimer.restart()
               }
               captureView._touchFocus = false
           } else {
               captureView._focusFailed = false
           }

           if (lockStatus != Camera.Searching && captureView._captureOnFocus) {
               captureView._captureOnFocus = false
               camera._completeCapture()
           } else if (lockStatus == Camera.Locked && !captureTimer.running) {
               focusTimer.restart()
           }
       }
    }

    CameraExtensions {
        id: extensions
        camera: camera

        device: Settings.global.cameraDevice

        //: Name of camera manufacturer to be written into captured photos
        //% "Jolla"
        manufacturer: qsTrId("camera-la-manufacturer")
        //: Name of camera model to be written into captured photos
        //% "Jolla"
        model: qsTrId("camera-la-model")

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

        viewfinderResolution: Settings.mode.viewfinderResolution

        onViewfinderResolutionChanged: captureView.reload()
        onDeviceChanged: captureView.reload()
    }

    Binding {
        target: captureView.viewfinder
        property: "x"
        value: captureView.isPortrait
               ? captureView._viewfinderPosition
               : 0
    }

    Binding {
        target: captureView.viewfinder
        property: "y"
        value: !captureView.isPortrait
                ? captureView._viewfinderPosition
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
        value: captureView._mirrorViewfinder
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
        ScriptAction {
            script: captureView.captured()
        }
    }

    SettingsOverlay {
        id: settingsOverlay

        width: captureView.width
        height: captureView.height

        isPortrait: captureView.isPortrait

        onClicked: {
            if (!captureView._captureOnFocus
                    && Settings.mode.focusDistance != Camera.FocusInfinity) {
                captureView._touchFocus = true

                if (Settings.mode.focusDistance == Camera.FocusAuto) {
                    // Translate and rotate the touch point into focusArea's space.
                    var focusPoint
                    switch ((360 - extensions.orientation) % 360) {
                    case 90:
                        focusPoint = Qt.point(
                                    mouse.y - ((height - focusArea.width) / 2),
                                    width - mouse.x);
                        break;
                    case 180:
                        focusPoint = Qt.point(
                                    width - mouse.x - ((width - focusArea.width) / 2),
                                    height - mouse.y);
                        break;
                    case 270:
                        focusPoint = Qt.point(
                                    height - mouse.y - ((height - focusArea.width) / 2),
                                    mouse.x);
                        break;
                    default:
                        focusPoint = Qt.point(
                                    mouse.x - ((width - focusArea.width) / 2),
                                    mouse.y);
                        break;
                    }

                    // Normalize the focus point.
                    focusPoint.x = focusPoint.x / focusArea.width
                    focusPoint.y = focusPoint.y / focusArea.height

                    // Mirror the point if the viewfinder is mirrored.
                    if (captureView._mirrorViewfinder) {
                        focusPoint.x = 1 - focusPoint.x
                    }

                    camera.focus.customFocusPoint = focusPoint
                }

                camera.searchAndLock()
            }
        }

        onPinchStarted: {
            // We're not getting notifications when the maximumDigitalZoom changes,
            // so update the value here.
            zoomIndicator.maximumZoom = camera.maximumDigitalZoom
        }

        onPinchUpdated: {
            camera.digitalZoom = Math.max(1, Math.min(
                        camera.digitalZoom + ((camera.maximumDigitalZoom - 1) * ((pinch.scale / Math.abs(pinch.previousScale) - 1))),
                        camera.maximumDigitalZoom))
            zoomIndicator.show()
        }

        shutter: MouseArea {
            id: captureButton

            width: Theme.itemSizeExtraLarge
            height: Theme.itemSizeExtraLarge

            z: settingsOverlay.inButtonLayout ? 1 : 0

            enabled: captureView._canCapture
                        && !captureView._captureOnFocus
                        && !volumeDown.pressed
                        && !volumeUp.pressed

            anchors.centerIn: parent

            onPressed: camera.autoFocus()

            onClicked: captureView._triggerCapture()

            Rectangle {
                radius: Theme.itemSizeSmall / 2
                width: Theme.itemSizeSmall
                height: Theme.itemSizeSmall

                anchors.centerIn: parent

                opacity: 0.6
                color: Theme.highlightDimmerColor
            }

            Image {
                id: shutterImage

                anchors.centerIn: parent

                opacity: {
                    if (captureTimer.running) {
                        return 0.1
                    } else if (captureButton.pressed) {
                        return 0.5
                    } else {
                        return 1.0
                    }
                }

                source: startRecordTimer.running || camera.videoRecorder.recorderState == CameraRecorder.RecordingState
                        ? "image://theme/icon-camera-stop?" + Theme.highlightColor
                        : "image://theme/icon-camera-shutter-release?" + (captureView._canCapture
                                ? Theme.highlightColor
                                : Theme.highlightDimmerColor)
            }

            Label {
                anchors.centerIn: parent
                text: Math.floor(captureView._captureCountdown + 1)
                visible: captureTimer.running
                opacity: captureView._captureCountdown % 1
                color: Theme.primaryColor
                font {
                    pixelSize: Theme.fontSizeHuge
                    weight: Font.Light
                }
            }
        }

        timer: Item {
            anchors {
                centerIn: parent
                horizontalCenterOffset: settingsOverlay.timerAlignment == Qt.AlignLeft
                        ? -(timerLabel.width + Theme.paddingMedium - Theme.itemSizeMedium) / 2
                        : (timerLabel.width + Theme.paddingMedium - Theme.itemSizeMedium) / 2
            }
            width: timerLabel.implicitWidth + (2 * Theme.paddingMedium)
            height: timerLabel.implicitHeight + (2 * Theme.paddingSmall)
            opacity: camera.captureMode == Camera.CaptureVideo ? 1 : 0
            Behavior on opacity { FadeAnimation {} }

            Rectangle {
                radius: Theme.paddingSmall / 2

                anchors.fill: parent
                color: Theme.highlightBackgroundColor
                opacity: 0.6
            }
            Label {
                id: timerLabel

                anchors.centerIn: parent

                text: Format.formatDuration(
                          captureView._recordingDuration,
                          captureView._recordingDuration >= 3600 ? Formatter.DurationLong : Formatter.DurationShort)
                font.pixelSize: Theme.fontSizeMedium

            }
        }

        // Viewfinder Grid
        Item {
            id: grid

            property real gridWidth: extensions.orientation % 180 == 0 ? focusArea.width : focusArea.height
            property real gridHeight: extensions.orientation % 180 == 0 ? focusArea.height : focusArea.width
            property real ambienceScale: Math.min(Screen.width, Screen.height) /
                                         Math.max(Screen.width, Screen.height)

            anchors.centerIn: parent

            visible: Settings.mode.viewfinderGrid != "none"
                     && camera.cameraStatus == Camera.ActiveStatus

            width: Settings.mode.viewfinderGrid == "ambience"
                   ? gridWidth * ambienceScale
                   : gridWidth / 3
            height: Settings.mode.viewfinderGrid == "ambience"
                    ? gridHeight * ambienceScale
                    : gridHeight / 3

            GridLine {
                anchors {
                    horizontalCenter: grid.horizontalCenter
                    verticalCenter: grid.top
                }
                width: grid.gridWidth
            }

            GridLine {
                anchors {
                    horizontalCenter: grid.horizontalCenter
                    verticalCenter: grid.bottom
                }
                width: grid.gridWidth
            }

            GridLine {
                anchors {
                    horizontalCenter: grid.left
                    verticalCenter: grid.verticalCenter
                }
                width: grid.gridHeight
                rotation: 90
            }

            GridLine {
                anchors {
                    horizontalCenter: grid.right
                    verticalCenter: grid.verticalCenter
                }
                width: grid.gridHeight
                rotation: 90
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

            Repeater {
                model: camera.focus.focusZones
                delegate: Item {
                    x: focusArea.width * (captureView._mirrorViewfinder
                                ? 1 - area.x - area.width
                                : area.x)
                    y: focusArea.height * area.y
                    width: focusArea.width * area.width
                    height: focusArea.height * area.height

                    visible: status != Camera.FocusAreaUnused

                    Rectangle {
                        anchors {
                            fill: focusRectangle
                            margins: -1
                        }
                        border {
                            width: Theme.paddingSmall
                            color: "black"
                        }
                        color: "#00000000"
                    }

                    Rectangle {
                        id: focusRectangle

                        width: Math.min(parent.width, parent.height)
                        height: width

                        opacity: 0.6
                        anchors.centerIn: parent
                        border {
                            width: Theme.paddingSmall - 2
                            color: status == Camera.FocusAreaFocused
                                        ? Theme.highlightColor
                                        : Theme.primaryColor
                        }
                        color: "#00000000"
                    }
                    Image {
                        anchors {
                            horizontalCenter: focusRectangle.right
                            verticalCenter: captureView.isPortrait
                                        ? focusRectangle.top
                                        : focusRectangle.bottom
                        }

                        source: "image://theme/icon-system-warning?" + Theme.highlightColor
                        visible: captureView._focusFailed
                        rotation: -focusArea.rotation
                    }

                    Image {
                        anchors {
                            horizontalCenter: focusRectangle.right
                            verticalCenter: captureView.isPortrait
                                        ? focusRectangle.top
                                        : focusRectangle.bottom
                        }

                        source: "image://theme/icon-camera-focus-infinity?" + Theme.highlightColor
                        visible: model.status == Camera.FocusAreaFocused
                                    && camera.focus.focusMode == Camera.FocusInfinity
                        rotation: -focusArea.rotation
                    }
                }
            }
        }

        ZoomIndicator {
            id: zoomIndicator
            anchors {
                top: parent.top
                topMargin: Theme.itemSizeMedium
                horizontalCenter: parent.horizontalCenter
            }

            zoom: camera.digitalZoom
            maximumZoom: camera.maximumDigitalZoom
        }

        Timer {
            id: focusTimer

            interval: 15000
            onTriggered: captureView._resetFocus()
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
        id: volumeUp
        enabled: keysResource.acquired
                    && camera.captureMode == Camera.CaptureStillImage
                    && !captureButton.pressed
                    && !captureView._captureOnFocus
        key: Qt.Key_VolumeUp
        onPressed: camera.autoFocus()
        onReleased: captureView._triggerCapture()
    }
    MediaKey {
        id: volumeDown
        enabled: volumeUp.enabled
        key: Qt.Key_VolumeDown
        onPressed: camera.autoFocus()
        onReleased: captureView._triggerCapture()
    }

    Permissions {
        enabled: captureView.activeFocus
                    && camera.captureMode == Camera.CaptureStillImage
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
