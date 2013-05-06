import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0
import "../compass"
import "SettingsIcons.js" as SettingsIcons

Compass {
    id: compass

    property int timer: 0

    property Camera camera

    buttonEnabled: camera.captureMode == Camera.CaptureStillImage
    keepSelection: camera.locks.focusStatus == CameraLocks.Searching
                || camera.locks.exposureStatus == CameraLocks.Searching

    topAction {
        smallIcon: SettingsIcons.exposure(modeSettings.exposureCompensation)
        largeIcon: "image://theme/icon-camera-exposure-compensation"
        enabled: compass.buttonEnabled && modeSettings.exposureConfigurable
        onActivated: compass.openMenu(exposureMenu)
    }
    bottomAction {
        smallIcon: SettingsIcons.timer(modeSettings.timer)
        largeIcon: "image://theme/icon-camera-timer"
        enabled: compass.buttonEnabled && modeSettings.timerConfigurable
        onActivated: compass.openMenu(timerMenu)
    }
    leftAction {
        smallIcon: compass.camera.locks.exposureStatus == CameraLocks.Locked
                ? "image://theme/icon-camera-zoom-in?" + theme.highlightColor
                : "image://theme/icon-camera-zoom-in"
        largeIcon: "image://theme/icon-camera-zoom-tele"
        enabled: compass.buttonEnabled && modeSettings.exposureConfigurable
        onActivated: {
            if (compass.camera.locks.exposureStatus == CameraLocks.Unlocked) {
                compass.camera.locks.lockExposure()
            } else {
                compass.camera.locks.unlockExposure()
            }
        }
    }
    rightAction {
        smallIcon: SettingsIcons.iso(modeSettings.iso)
        largeIcon: "image://theme/icon-camera-iso"
        enabled: compass.buttonEnabled && modeSettings.isoConfigurable
        onActivated: compass.openMenu(isoMenu)
    }

    icon: "image://theme/icon-camera-settings?" + theme.highlightColor

    Component {
        id: timerMenu

        CompassMenu {
            settings: modeSettings
            property: "timer"
            model: [ 0, 3, 15, 20 ]
            delegate: CompassMenuItem { value: modelData; icon: SettingsIcons.timer(modelData) }
        }
    }

    Component {
        id: exposureMenu

        CompassMenu {
            settings: modeSettings
            property: "exposureCompensation"
            model: [ -4, -3, -2, -1, 0, 1, 2, 3, 4 ]
            delegate: CompassMenuItem { value: modelData; icon: SettingsIcons.exposure(modelData) }
        }
    }

    Component {
        id: isoMenu

        CompassMenu {
            settings: modeSettings
            property: "iso"
            model: [ 0, 100, 200, 400, 800, 1600 ]
            delegate: CompassMenuItem { value: modelData; icon: SettingsIcons.iso(modelData) }
        }
    }
}
