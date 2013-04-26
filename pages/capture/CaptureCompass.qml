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

    function flashIcon(mode) {
        switch (mode) {
        case Camera.FlashAuto:
            return "image://theme/icon-s-cloud-upload"
        case Camera.FlashOff:
            return "image://theme/icon-s-cloud-upload"
        case Camera.FlashOn:
            return "image://theme/icon-s-cloud-upload"
        case Camera.FlashRedEyeReduction:
            return "image://theme/icon-s-cloud-upload"
        default:
            return ""
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

    north {
        smallIcon: "image://theme/icon-s-cloud-upload"
        largeIcon: "image://theme/icon-s-cloud-upload"
        enabled: !compass._recording
    }
    west {
        smallIcon: flashIcon(settings.flash)
        largeIcon: flashIcon(settings.flash)
        enabled: !compass._recording && !(settings.shootingModeProperties & Settings.Flash)
        onActivated: compass.openMenu(flashMenu)
    }
    east {
        smallIcon: "image://theme/icon-cover-sync"
        largeIcon: "image://theme/icon-cover-sync"
        enabled: !compass._recording && !(settings.shootingModeProperties & Settings.Exposure)
        onActivated: compass.openMenu(exposureMenu)
    }
    south {
        smallIcon: !compass._recording ? "image://theme/icon-cover-new" : "image://theme/icon-cover-sync"
        largeIcon: !compass._showStopIcon ? "image://theme/icon-cover-new" : "image://theme/icon-cover-sync"
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

    icon: "image://theme/icon-cover-camera"


    keepSelection: camera.captureMode == Camera.CaptureVideo && camera.cameraStatus != Camera.ActiveStatus

    Component {
        id: flashMenu

        CompassMenu {
            //% "flash"
            title: qsTrId("camera-me-flash")

             CompassMenuIcon {
                icon: flashIcon(Camera.FlashAuto)
                onClicked: settings.flash = Camera.FlashAuto
            }
            CompassMenuIcon {
                icon: flashIcon(Camera.FlashOff)
                onClicked: settings.flash = Camera.FlashOff
            }
            CompassMenuIcon {
                icon: flashIcon(Camera.FlashOn)
                onClicked: settings.flash = Camera.FlashOn
            }
            CompassMenuIcon {
                icon: flashIcon(Camera.FlashRedEyeReduction)
                onClicked: settings.flash = Camera.FlashRedEyeReduction
            }
        }
    }

    Component {
        id: exposureMenu

        CompassMenu {
            //% "exposure"
            title: qsTrId("camera-me-exposure")

            CompassMenuText { label: "-2"; onClicked: settings.exposure = -2 }
            CompassMenuText { label: "-1"; onClicked: settings.exposure = -1 }
            CompassMenuText { label: "0"; onClicked: settings.exposure = 0 }
            CompassMenuText { label: "+1"; onClicked: settings.exposure = 1 }
            CompassMenuText { label: "+2"; onClicked: settings.exposure = 2 }
        }
    }
}
