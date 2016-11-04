import QtQuick 2.4
import QtMultimedia 5.4
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import com.jolla.camera 1.0
import org.nemomobile.policy 1.0
import org.nemomobile.ngf 1.0
import org.nemomobile.dbus 2.0
import QtSystemInfo 5.0

import "../settings"

FocusScope {
    id: captureView

    property bool active
    property bool windowVisible
    property int orientation
    property int effectiveIso: Settings.mode.iso
    property bool inButtonLayout: captureOverlay == null || captureOverlay.inButtonLayout

    readonly property int viewfinderOrientation: {
        var rotation = 0
        switch (captureView.orientation) {
        case Orientation.Landscape: rotation = 90; break;
        case Orientation.PortraitInverted: rotation = 180; break;
        case Orientation.LandscapeInverted: rotation = 270; break;
        }
        return camera.position == Camera.FrontFace
                ? (720 + camera.orientation - rotation) % 360
                : (720 + camera.orientation + rotation) % 360
    }
    property int captureOrientation

    property alias camera: camera
    property QtObject viewfinder

    readonly property bool recording: active && camera.videoRecorder.recorderState == CameraRecorder.RecordingState

    property bool _complete
    property bool _unload

    property bool touchFocusSupported: (camera.focus.focusMode == Camera.FocusAuto || camera.focus.focusMode == Camera.FocusContinuous)
                                       && camera.captureMode != Camera.CaptureVideo

    property bool _captureOnFocus
    property real _captureCountdown

    readonly property real _viewfinderPosition: orientation == Orientation.Portrait || orientation == Orientation.Landscape
                                                ? parent.x + x
                                                : -parent.x - x

    readonly property bool isPortrait: orientation == Orientation.Portrait
                || orientation == Orientation.PortraitInverted
    readonly property bool effectiveActive: ((activeFocus && active) || (windowVisible && recording)) && _applicationActive

    readonly property bool _canCapture: (camera.captureMode == Camera.CaptureStillImage && camera.imageCapture.ready)
                || (camera.captureMode == Camera.CaptureVideo && camera.videoRecorder.recorderStatus >= CameraRecorder.LoadedStatus)

    property bool captureButtonPressed: !!captureOverlay && captureOverlay.captureButtonPressed
    readonly property bool _capturePending: volumeUp.pressed || volumeDown.pressed || captureButtonPressed

    property bool _captureQueued
    property bool captureBusy
    onCaptureBusyChanged: {
        if (!captureBusy && _captureQueued) {
            _captureQueued = false
            camera.captureImage()
        }
    }

    readonly property bool _mirrorViewfinder: Settings.global.cameraDevice == "secondary"

    readonly property bool _applicationActive: Qt.application.state == Qt.ApplicationActive
    on_ApplicationActiveChanged: if (_applicationActive) flashlightServiceProbe.checkFlashlightServiceStatus()

    property string cameraDevice: Settings.cameraDevice

    property var captureOverlay: null

    signal recordingStopped(url url, string mimeType)
    signal loaded
    signal captured

    Item {
        id: captureSnapshot
        property alias sourceItem: captureSnapshotEffect.sourceItem
        visible: false
        width: parent.width
        height: parent.height
        ShaderEffectSource {
            id: captureSnapshotEffect
            hideSource: false
            live: false
            anchors.centerIn: parent
            width: isPortrait ? parent.width : parent.height
            height: isPortrait ? parent.height : parent.width
            rotation: -page.rotation
        }
    }

    function reload() {
        if (captureView._complete) {
            captureView._unload = true
        }
    }

    function setFocusPoint(point) {
        focusTimer.restart()
        camera.unlock()
        camera.focus.customFocusPoint = point
    }

    function _resetFocus() {
        focusTimer.running = false
        camera.unlock()
    }

    function _triggerCapture() {
        if (captureTimer.running) {
            camera.unlock()
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

    on_CanCaptureChanged: {
        if (!_canCapture) {
            startRecordTimer.running = false
        }
    }

    Component.onCompleted: {
        flashlightServiceProbe.checkFlashlightServiceStatus()
        camera.deviceId = Settings.global.cameraDevice
        loadOverlay()
        _complete = true
    }

    onCameraDeviceChanged: {
        // We must call reload() first so camera reaches UnloadedState
        // If we switch Camera::deviceId then camera will not start again
        // which seems to be a bug in QtMultimedia
        // Qt bug: https://bugreports.qt.io/browse/QTBUG-46995
        reload()
        _resetFocus()
        camera.deviceId = Settings.cameraDevice
        Settings.global.cameraDevice = Settings.cameraDevice
    }

    onActiveChanged: {
        if (!active) {
            _resetFocus()
        }
    }

    Timer {
        id: reloadTimer
        interval: 100
        running: captureView._unload && camera.cameraStatus == Camera.UnloadedStatus
        onTriggered: {
            captureView._unload = false
        }
    }

    Timer {
        id: startFailedTimer
        interval: 2000
        onTriggered: {
            if (camera.cameraStatus === Camera.StartingStatus) {
                captureView.reload()
            }
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
            captureOverlay.writeMetaData()
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

    onRecordingStopped: {
        captureModel.appendCapture(
                    url,
                    mimeType,
                    captureOrientation,
                    camera.videoRecorder.duration / 1000,
                    camera.videoRecorder.resolution)
    }

    Camera {
        id: camera

        function autoFocus() {
            captureOverlay.close()
            if (camera.captureMode == Camera.CaptureStillImage
                    && focus.focusMode != Camera.FocusInfinity
                    && focus.focusMode != Camera.FocusHyperfocal
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
            if (captureBusy) {
                _captureQueued = true
                return
            }

            captureBusy = true
            captureOverlay.writeMetaData()

            shutterEvent.play()
            captureAnimation.start()

            camera.imageCapture.captureToLocation(Settings.photoCapturePath('jpg'))

            if (focusTimer.running) {
                // Changing focus mode will reset focus point, make sure it stays same
                var focusPoint = Qt.point(camera.focus.customFocusPoint.x, camera.focus.customFocusPoint.y)
                focusTimer.restart()
                camera.focus.customFocusPoint = focusPoint
            }
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

        onCaptureModeChanged: captureView._resetFocus()

        cameraState: captureView._complete && captureView.effectiveActive && !captureView._unload
                    ? Camera.ActiveState
                    : Camera.UnloadedState

        onCameraStateChanged: {
            if (cameraState == Camera.ActiveState && captureOverlay) {
                captureView.loaded()
            }
        }

        onCameraStatusChanged: {
            if (camera.cameraStatus == Camera.StartingStatus) {
                startFailedTimer.restart()
            } else {
                startFailedTimer.stop()
            }
        }

        imageCapture {
            resolution: Settings.mode.imageResolution
            onResolutionChanged: reload()

            onImageSaved: {
                camera.unlock()
                captureBusy = false

                captureModel.appendCapture(
                            path,
                            "image/jpeg",
                            captureOrientation,
                            0,
                            camera.imageCapture.resolution)
            }
            onCaptureFailed: {
                camera.unlock()
                captureBusy = false
            }
        }
        videoRecorder {
            resolution: Settings.mode.videoResolution
            onResolutionChanged: reload()
            frameRate: 30
            audioChannels: 2
            audioSampleRate: Settings.global.audioSampleRate
            audioCodec: Settings.global.audioCodec
            videoCodec: Settings.global.videoCodec
            mediaContainer: Settings.global.mediaContainer

            videoEncodingMode: Settings.global.videoEncodingMode
            videoBitRate: Settings.global.videoBitRate
        }
        focus {
            focusMode: Settings.mode.focusDistanceValues.indexOf(Camera.FocusContinuous) >= 0
                       ? Camera.FocusContinuous : Settings.mode.focusDistanceValues[0]
            focusPointMode: focusTimer.running ? Camera.FocusPointCustom : Camera.FocusPointAuto
        }
        flash.mode: Settings.mode.flash
        imageProcessing.whiteBalanceMode: Settings.mode.whiteBalance

        exposure {
            exposureMode: Settings.mode.exposureMode
            exposureCompensation: Settings.mode.exposureCompensation / 2.0
            meteringMode: Settings.mode.meteringMode
        }

        viewfinder {
            resolution: Settings.mode.viewfinderResolution
            minimumFrameRate: 30
            maximumFrameRate: 30
        }

        metaData {
            orientation: captureView.captureOrientation
        }

        onDeviceIdChanged: captureView.reload()
        viewfinder.onResolutionChanged: captureView.reload()
        focus.onFocusModeChanged: camera.unlock()

        onLockStatusChanged: {
            if (lockStatus != Camera.Searching && captureView._captureOnFocus) {
                captureView._captureOnFocus = false
                camera._completeCapture()
            }
        }
    }

    DeviceInfo {
        Component.onCompleted: {
            camera.metaData.cameraModel = model()
            camera.metaData.cameraManufacturer = manufacturer()
        }
    }

    CameraExtensions {
        id: extensions
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

        PropertyAction {
            target: captureSnapshot
            property: "sourceItem"
            value: viewfinder
        }
        ScriptAction {
            script: captureSnapshotEffect.scheduleUpdate()
        }
        PropertyAction {
            target: captureSnapshot
            property: "visible"
            value: true
        }
        ParallelAnimation {
            XAnimator {
                target: captureSnapshot
                from: 0
                to: captureView.isPortrait ? -captureView.height : -captureView.width
                duration: 250
                easing.type: Easing.InQuad
            }
            ScaleAnimator {
                target: captureSnapshotEffect
                from: 1.0
                to: 0.6
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }

        PropertyAction {
            target: captureSnapshot
            property: "visible"
            value: false
        }
        PropertyAction {
            target: captureSnapshot
            property: "sourceItem"
            value: null
        }
        ScriptAction {
            script: captureView.captured()
        }
    }

    property Component overlayComponent
    property var overlayIncubator

    function loadOverlay() {
        overlayComponent = Qt.createComponent("CaptureOverlay.qml", Component.Asynchronous, captureView)
        if (overlayComponent) {
            if (overlayComponent.status === Component.Ready) {
                incubateOverlay()
            } else if (overlayComponent.status === Component.Loading) {
                overlayComponent.statusChanged.connect(
                    function(status) {
                        if (overlayComponent) {
                            if (status == Component.Ready) {
                                incubateOverlay()
                            } else if (status == Component.Error) {
                                console.warn(overlayComponent.errorString())
                            }
                        }
                    })
            } else {
                console.log("Error loading capture overlay", overlayComponent.errorString())
            }
        }
    }

    function incubateOverlay() {
        overlayIncubator = overlayComponent.incubateObject(captureView, {
                                                                      "captureView": captureView,
                                                                      "camera": camera,
                                                                      "focusArea": focusArea
                                                                  }, Qt.Asynchronous)
        overlayIncubator.onStatusChanged = function(status) {
            if (status == Component.Ready) {
                captureOverlay = overlayIncubator.object
                overlayFadeIn.start()
                overlayIncubator = null
                if (camera.cameraState == Camera.ActiveState && captureOverlay) {
                    captureView.loaded()
                }
            } else if (status == Component.Error) {
                console.log("Failed to create capture overlay")
                overlayIncubator = null
            }
        }
    }

    FadeAnimator {
        id: overlayFadeIn
        target: captureOverlay
        to: 1.0
        duration: 100
    }

    Item {
        id: focusArea

        width: Screen.width
               * camera.viewfinder.resolution.width
               / camera.viewfinder.resolution.height
        height: Screen.width

        rotation: -captureView.viewfinderOrientation
        anchors.centerIn: parent
        opacity: captureOverlay ? 1.0 - captureOverlay.settingsOpacity : 1.0

        Repeater {
            model: camera.focus.focusZones
            delegate: Item {
                x: focusArea.width * (captureView._mirrorViewfinder
                                      ? 1 - area.x - area.width
                                      : area.x)
                y: focusArea.height * area.y
                width: focusArea.width * area.width
                height: focusArea.height * area.height

                visible: status != Camera.FocusAreaUnused && camera.focus.focusPointMode == Camera.FocusPointCustom

                Rectangle {
                    id: focusRectangle

                    width: Math.min(parent.width, parent.height)
                    height: width
                    anchors.centerIn: parent
                    radius: width / 2
                    border {
                        width: Math.round(Theme.pixelRatio * 2)
                        color: status == Camera.FocusAreaFocused ? Theme.highlightColor : "white"
                    }
                    color: "#00000000"
                }
            }
        }
    }

    Timer {
        id: focusTimer

        interval: 10000
        onTriggered: captureView._resetFocus()
    }

    MediaKey {
        id: volumeUp
        enabled: camera.imageCapture.ready
                    && keysResource.acquired
                    && camera.captureMode == Camera.CaptureStillImage
                    && !captureButtonPressed
                    && !captureView._captureOnFocus
        key: Qt.Key_VolumeUp
        onPressed: camera.autoFocus()
        onReleased: {
            if (enabled)
                captureView._triggerCapture()
        }
    }
    MediaKey {
        id: volumeDown
        enabled: volumeUp.enabled
        key: Qt.Key_VolumeDown
        onPressed: camera.autoFocus()
        onReleased: {
            if (enabled)
                captureView._triggerCapture()
        }
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

    DBusInterface {
        id: flashlightServiceProbe
        service: "org.freedesktop.DBus"
        path: "/org/freedesktop/DBus"
        iface: "org.freedesktop.DBus"
        property bool flashlightServiceActive
        onFlashlightServiceActiveChanged: {
            if (flashlightServiceActive) {
                if (flashlightComponentLoader.sourceComponent == null || flashlightComponentLoader.sourceComponent == undefined) {
                    flashlightComponentLoader.sourceComponent = flashlightComponent
                } else {
                    flashlightComponentLoader.item.toggleFlashlight()
                }
            }
        }
        function checkFlashlightServiceStatus() {
            var probe = flashlightServiceProbe // cache id resolution to avoid context destruction issues
            typedCall('NameHasOwner',
                      { 'type': 's', 'value': 'com.jolla.settings.system.flashlight' },
                        function(result) { probe.flashlightServiceActive = false; probe.flashlightServiceActive = result }, // twiddle so that the change-handler is invoked
                        function() { probe.flashlightServiceActive = false; probe.flashlightServiceActive = true })         // assume true in failed case, to ensure we turn it off
        }
    }

    Loader { id: flashlightComponentLoader }

    Component {
        id: flashlightComponent
        DBusInterface {
            id: flashlightDbus
            bus: DBusInterface.SessionBus
            service: "com.jolla.settings.system.flashlight"
            path: "/com/jolla/settings/system/flashlight"
            iface: "com.jolla.settings.system.flashlight"
            Component.onCompleted: toggleFlashlight()
            function toggleFlashlight() {
                var isOn = flashlightDbus.getProperty("flashlightOn")
                if (isOn) flashlightDbus.call("toggleFlashlight")
            }
        }
    }
}
