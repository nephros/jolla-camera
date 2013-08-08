import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import "../compass"
import "../settings/SettingsIcons.js" as SettingsIcons

Compass {
    id: compass

    property Camera camera
    interactive: camera.captureMode == Camera.CaptureStillImage

    function _startRecording() {
        switch (camera.cameraStatus) {
        case Camera.ActiveStatus:
            camera.cameraStatusChanged.disconnect(_startRecording)
            camera.outputLocation = Settings.videoCapturePath("mp4")
            camera.videoRecorder.record()
            keepSelection = false
            break;
        case Camera.UnavailableStatus:
        case Camera.UnloadedStatus:
        case Camera.StandbyStatus:
            camera.cameraStatusChanged.disconnect(_startRecording)
            camera.captureMode = Camera.CaptureStillImage
            keepSelection = false
            break;
        }
    }

    onInteractiveChanged: {
        if (interactive) {
            captureOpacity.restart()
        } else {
            captureIcon.opacity = 0
        }
    }

    leftAction {
        smallIcon: SettingsIcons.meteringMode(Camera, Settings.mode.meteringMode)
        largeIcon: "image://theme/icon-camera-metering-mode"
        enabled: Settings.mode.meteringModeConfigurable
        onActivated: compass.openMenu(meteringMenu)
    }
    topAction {
        smallIcon: SettingsIcons.flash(Camera, Settings.mode.flash)
        largeIcon: "image://theme/icon-camera-flash"
        enabled: Settings.mode.flashConfigurable
        onActivated: compass.openMenu(flashMenu)
    }
    rightAction {
        smallIcon: "image://theme/icon-camera-wb-default"
        largeIcon: "image://theme/icon-camera-whitebalance"
        enabled: Settings.mode.whiteBalanceConfigurable
        onActivated: compass.openMenu(whiteBalanceMenu)
    }
    bottomAction {
        smallIcon: "image://theme/icon-camera-video"
        largeIcon: "image://theme/icon-camera-record"
        onActivated: {
            // Don't try and start recording until the camera has switched modes.
            keepSelection = true
            camera.cameraStatusChanged.connect(compass._startRecording)
            camera.captureMode = Camera.CaptureVideo
        }
    }

    onClicked: {
        if (camera.captureMode == Camera.CaptureStillImage) {
            camera.imageCapture.captureToLocation(Settings.photoCapturePath('jpg'))
        } else {
            camera.videoRecorder.stop()
            camera.captureMode = Camera.CaptureStillImage
        }
    }

    Image {
        id: captureIcon
        anchors.centerIn: parent
        source: "image://theme/icon-camera-shutter-release?" + Theme.highlightColor
        FadeAnimation on opacity { id: captureOpacity; to: 1 }
    }

    Image {
        anchors.centerIn: parent
        source: "image://theme/icon-camera-stop?" + Theme.highlightColor
        opacity: 1 - captureIcon.opacity
    }

    Component {
        id: meteringMenu

        CompassMenu {
            settings: Settings.mode
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
            settings: Settings.mode
            property: "flash"
            model: [
                Camera.FlashAuto,
                Camera.FlashOff,
                Camera.FlashOn
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
            settings: Settings.mode
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
