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

    property int metering: 0

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
            switch (compass.metering) {
            case 0:
                return "image://theme/icon-camera-metering-matrix"
            case 1:
                return "image://theme/icon-camera-metering-spot"
            case 2:
                return "image://theme/icon-camera-metering-weighted"
            }
        }
        largeIcon: "image://theme/icon-camera-metering-mode"
        enabled: !compass._recording
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

    icon: "image://theme/icon-camera-shutter-release"

    keepSelection: camera.captureMode == Camera.CaptureVideo && camera.cameraStatus != Camera.ActiveStatus


    Component {
        id: meteringMenu

        CompassMenu {
            //% "metering"
            title: qsTrId("camera-me-metering-mode")

             CompassMenuItem {
                icon: "image://theme/icon-camera-metering-matrix"
                onClicked: compass.metering = 0
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-metering-spot"
                onClicked: compass.metering = 1
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-metering-weighted"
                onClicked: compass.metering = 2
            }
        }
    }

    Component {
        id: flashMenu

        CompassMenu {
            //% "flash"
            title: qsTrId("camera-me-flash")

             CompassMenuItem {
                icon: "image://theme/icon-camera-flash-automatic"
                onClicked: settings.flash = Camera.FlashAuto
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-flash-off"
                onClicked: settings.flash = Camera.FlashOff
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-flash-on"
                onClicked: settings.flash = Camera.FlashOn
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-flash-redeye"
                onClicked: settings.flash = Camera.FlashRedEyeReduction
            }
        }
    }

    Component {
        id: exposureMenu

        CompassMenu {
            //% "exposure"
            title: qsTrId("camera-me-exposure")

            CompassMenuItem {
                icon: "image://theme/icon-camera-ec-minus2"
                onClicked: settings.exposureCompensation = -4
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-ec-minus15"
                onClicked: settings.exposureCompensation = -3
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-ec-minus1"
                onClicked: settings.exposureCompensation = -2
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-exposure-compensation"
                onClicked: settings.exposureCompensation = 0
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-ec-plus1"
                onClicked: settings.exposureCompensation = 2
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-ec-plus15"
                onClicked: settings.exposureCompensation = 3
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-ec-plus2"
                onClicked: settings.exposureCompensation = 4
            }
        }
    }
}
