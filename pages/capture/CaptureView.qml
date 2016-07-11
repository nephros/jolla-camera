import QtQuick 2.0
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

    readonly property bool isPortrait: orientation == Orientation.Portrait
                || orientation == Orientation.PortraitInverted
    readonly property bool effectiveActive: ((activeFocus && active) || (windowVisible && recording)) && _applicationActive

    readonly property bool _canCapture: (camera.captureMode == Camera.CaptureStillImage && camera.imageCapture.ready)
                || (camera.captureMode == Camera.CaptureVideo && camera.videoRecorder.recorderStatus >= CameraRecorder.LoadedStatus)

    readonly property int _stillFocus: !_touchFocus || Settings.mode.focusDistance != Camera.FocusContinuous
                ? Settings.mode.focusDistance
                : Camera.FocusAuto

    property bool captureButtonPressed: !!captureOverlay && captureOverlay.captureButtonPressed
    readonly property bool _capturePending: _captureOnFocus
                || volumeUp.pressed
                || volumeDown.pressed
                || captureButtonPressed

    readonly property bool _mirrorViewfinder: Settings.global.cameraDevice == "secondary"

    readonly property bool _applicationActive: Qt.application.state == Qt.ApplicationActive
    on_ApplicationActiveChanged: if (_applicationActive) flashlightServiceProbe.checkFlashlightServiceStatus()

    property string cameraDevice: Settings.cameraDevice

    property var captureOverlay: null

    signal recordingStopped(url url, string mimeType)
    signal loaded
    signal captured

    function reload() {
        if (captureView._complete) {
            captureView._unload = true
        }
    }

    function _resetFocus() {
        focusTimer.running = false
        _touchFocus = false
        _focusFailed = false
        camera.focus.customFocusPoint = Qt.point(0.5, 0.5)
        camera.unlock()
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
        camera.deviceId = Settings.cameraDevice
        Settings.global.cameraDevice = Settings.cameraDevice
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
        interval: 1200
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

    Camera {
        id: camera

        function autoFocus() {
            captureOverlay.close()
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
            captureOverlay.writeMetaData()
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

            videoEncodingMode: Settings.global.videoEncodingMode
            videoBitRate: Settings.global.videoBitRate
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
                        if (overlayComponent && status == Component.Ready) {
                            incubateOverlay()
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
                        width: Screen.sizeCategory >= Screen.Large ? Theme.paddingSmall * 0.5 : Theme.paddingSmall * 0.75
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
                                && camera.focus.focusMode != Camera.FocusInfinity
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
                    visible: camera.focus.focusMode == Camera.FocusInfinity
                    rotation: -focusArea.rotation
                }
            }
        }
    }

    Timer {
        id: focusTimer

        interval: 15000
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
