import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0
import "../compass"

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

    function startRecording() {
        switch (camera.cameraStatus) {
        case Camera.ActiveStatus:
            camera.cameraStatusChanged.disconnect(startRecording)
            camera.videoRecorder.record()
            break;
        case Camera.UnavailableStatus:
        case Camera.UnloadedStatus:
        case Camera.StandbyStatus:
            camera.cameraStatusChanged.disconnect(startRecording)
            camera.captureMode = Camera.CaptureStillImage
            break;
        }
    }

    topAction {
        smallIcon: {
            switch (settings.meteringMode) {
            case Camera.MeteringMatrix:
                return "image://theme/icon-camera-metering-matrix"
            case Camera.MeteringAverage:
                return "image://theme/icon-camera-metering-weighted"
            case Camera.MeteringSpot:
                return "image://theme/icon-camera-metering-spot"
            }
        }
        largeIcon: "image://theme/icon-camera-metering-mode"
        enabled: !compass._recording && !(settings.shootingModeProperties & Settings.MeteringMode)
        onActivated: compass.openMenu(meteringMenu)
    }
    leftAction {
        smallIcon: {
            switch (settings.flash) {
            case Camera.FlashAuto:
                return "image://theme/icon-camera-flash-automatic"
            case Camera.FlashOff:
                return "image://theme/icon-camera-flash-off"
            case Camera.FlashOn:
                return "image://theme/icon-camera-flash-on"
            case Camera.FlashRedEyeReduction:
                return "image://theme/icon-camera-flash-redeye"
            }
        }
        largeIcon: "image://theme/icon-camera-flash"
        enabled: !compass._recording && !(settings.shootingModeProperties & Settings.Flash)
        onActivated: compass.openMenu(flashMenu)
    }
    rightAction {
        smallIcon: {    // Exposure is value * 2 so it can be stored as an integer
            switch (settings.exposureCompensation) {
            case -4:
                return "image://theme/icon-camera-ec-minus2"
            case -3:
                return "image://theme/icon-camera-ec-minus15"
            case -2:
                return "image://theme/icon-camera-ec-minus1"
            case 0:
                return "image://theme/icon-camera-exposure-compensation"
            case 2:
                return "image://theme/icon-camera-ec-plus1"
            case 3:
                return "image://theme/icon-camera-ec-plus15"
            case 4:
                return "image://theme/icon-camera-ec-plus2"
            }
        }

        largeIcon: "image://theme/icon-camera-exposure-compensation"
        enabled: !compass._recording && !(settings.shootingModeProperties & Settings.Exposure)
        onActivated: compass.openMenu(exposureMenu)
    }
    bottomAction {
        smallIcon: !compass._recording ? "image://theme/icon-camera-record" : "image://theme/icon-camera-stop"
        largeIcon: !compass._showStopIcon ? "image://theme/icon-camera-record" : "image://theme/icon-camera-stop"
        onActivated: {
            if (!compass._recording) {
                camera.captureMode = Camera.CaptureVideo
                // Don't try and start recording until the camera has switched modes.
                camera.cameraStatusChanged.connect(compass.startRecording)
            } else {
                camera.videoRecorder.stop()
                camera.captureMode = Camera.CaptureStillImage
            }
        }
    }

    icon: "image://theme/icon-camera-shutter-release?" + theme.highlightColor

    keepSelection: camera.captureMode == Camera.CaptureVideo && camera.cameraStatus != Camera.ActiveStatus

    Component {
        id: meteringMenu

        CompassMenu {
            property: "meteringMode"
            CompassMenuItem {
                icon: "image://theme/icon-camera-metering-matrix"
                value: Camera.MeteringMatrix
            }
            CompassMenuItem {
                 icon: "image://theme/icon-camera-metering-weighted"
                 value: Camera.MeteringAverage
             }
            CompassMenuItem {
                icon: "image://theme/icon-camera-metering-spot"
                value: Camera.MeteringSpot
            }
        }
    }

    Component {
        id: flashMenu

        CompassMenu {
            property: "flash"
            CompassMenuItem {
                icon: "image://theme/icon-camera-flash-automatic"
                value: Camera.FlashAuto
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-flash-off"
                value: Camera.FlashOff
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-flash-on"
                value: Camera.FlashOn
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-flash-redeye"
                value: Camera.FlashRedEyeReduction
            }
        }
    }

    Component {
        id: exposureMenu

        CompassMenu {
            property: "exposureCompensation"
            CompassMenuItem {
                icon: "image://theme/icon-camera-ec-minus2"
                value: -4
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-ec-minus15"
                value: -3
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-ec-minus1"
                value: -2
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-exposure-compensation"
                value: 0
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-ec-plus1"
                value: 2
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-ec-plus15"
                value: 3
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-ec-plus2"
                value: 4
            }
        }
    }
}
