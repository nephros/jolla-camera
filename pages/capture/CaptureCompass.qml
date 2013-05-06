import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0
import "../compass"
import "../settings/SettingsIcons.js" as SettingsIcons

Compass {
    id: compass

    property Camera camera

    property bool _recording: camera.videoRecorder.recorderState == CameraRecorder.RecordingState
    property bool _showStopIcon: true

    onAnimatingChanged: {
        if (!animating) {
            _showStopIcon = _recording
        }
    }

    function _startRecording() {
        switch (camera.cameraStatus) {
        case Camera.ActiveStatus:
            camera.cameraStatusChanged.disconnect(_startRecording)
            camera.videoRecorder.record()
            break;
        case Camera.UnavailableStatus:
        case Camera.UnloadedStatus:
        case Camera.StandbyStatus:
            camera.cameraStatusChanged.disconnect(_startRecording)
            camera.captureMode = Camera.CaptureStillImage
            break;
        }
    }

    leftAction {
        smallIcon: SettingsIcons.meteringMode(Camera, settings.meteringMode)
        largeIcon: "image://theme/icon-camera-metering-mode"
        enabled: !compass._recording && !(settings.shootingModeProperties & Settings.MeteringMode)
        onActivated: compass.openMenu(meteringMenu)
    }
    topAction {
        smallIcon: SettingsIcons.flash(Camera, settings.flash)
        largeIcon: "image://theme/icon-camera-flash"
        enabled: !compass._recording && !(settings.shootingModeProperties & Settings.Flash)
        onActivated: compass.openMenu(flashMenu)
    }
    rightAction {
        smallIcon: "image://theme/icon-camera-wb-default"
        largeIcon: "image://theme/icon-camera-whitebalance"
        enabled: !compass._recording && !(settings.shootingModeProperties & Settings.WhiteBalance)
        onActivated: compass.openMenu(whiteBalanceMenu)
    }
    bottomAction {
        smallIcon: "image://theme/icon-camera-video"
        largeIcon: "image://theme/icon-camera-record"
        enabled: !compass._recording
        onActivated: {
            // Don't try and start recording until the camera has switched modes.
            camera.cameraStatusChanged.connect(compass._startRecording)
            camera.captureMode = Camera.CaptureVideo
        }
    }

    icon: !_recording
          ? "image://theme/icon-camera-shutter-release?" + theme.highlightColor
          : "image://theme/icon-camera-stop?" + theme.highlightColor

    keepSelection: camera.captureMode == Camera.CaptureVideo && camera.cameraStatus != Camera.ActiveStatus

    onClicked: {
        if (camera.captureMode == Camera.CaptureStillImage) {
            camera.imageCapture.capture()
        } else {
            camera.videoRecorder.stop()
            camera.captureMode = Camera.CaptureStillImage
        }
    }

    Component {
        id: meteringMenu

        CompassMenu {
            property: "meteringMode"
            model: [
                Camera.MeteringMatrix,
                Camera.MeteringAverage,
                Camera.MeteringSpot
            ]
            delegate:  CompassMenuItem {
                value: modelData
                icon: SettingsIcons.meteringMode(Camera, modelData)
            }
        }
    }

    Component {
        id: flashMenu

        CompassMenu {
            property: "flash"
            model: [
                Camera.FlashAuto,
                Camera.FlashOff,
                Camera.FlashOn,
                Camera.FlashRedEyeReduction
            ]
            delegate: CompassMenuItem {
                value: modelData
                icon: SettingsIcons.flash(Camera, modelData)
            }
        }
    }

    Component {
        id: whiteBalanceMenu
        CompassMenu {
            property: "whiteBalance"
            model: [
                CameraImageProcessing.WhiteBalanceAuto,
                CameraImageProcessing.WhiteBalanceSunlight,
                CameraImageProcessing.WhiteBalanceCloudy,
                CameraImageProcessing.WhiteBalanceShade,
                CameraImageProcessing.WhiteBalanceSunset,
                CameraImageProcessing.WhiteBalanceFluorescent,
                CameraImageProcessing.WhiteBalanceTungsten
            ]
            delegate: CompassMenuItem {
                value: modelData
                icon: SettingsIcons.whiteBalance(CameraImageProcessing, modelData)
            }
        }
    }
}
