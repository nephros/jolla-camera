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
    topAction {
        smallIcon: {
            switch (settings.flash) {
            case Camera.FlashAuto:
                return "image://theme/icon-camera-flash"
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
                icon: "image://theme/icon-camera-flash"
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
        id: whiteBalanceMenu
        CompassMenu {
            property: "whiteBalance"
            CompassMenuItem {
                icon: "image://theme/icon-camera-wb-automatic"
                value: CameraImageProcessing.WhiteBalanceAuto
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-wb-fluorecent"
                value: CameraImageProcessing.WhiteBalanceFluorescent
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-wb-shade"
                value: CameraImageProcessing.WhiteBalanceShade
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-wb-sunset"
                value: CameraImageProcessing.WhiteBalanceSunset
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-wb-tungsten"
                value: CameraImageProcessing.WhiteBalanceTungsten
            }
        }
    }
}
