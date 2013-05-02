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
        smallIcon: SettingsIcons.exposure(settings.exposureCompensation)
        largeIcon: "image://theme/icon-camera-exposure-compensation"
        enabled: compass.buttonEnabled && !(settings.shootingModeProperties & Settings.Exposure)
        onActivated: compass.openMenu(exposureMenu)
    }
    bottomAction {
        smallIcon: SettingsIcons.timer(settings.timer)
        largeIcon: "image://theme/icon-camera-timer"
        enabled: compass.buttonEnabled && !(settings.shootingModeProperties & Settings.Timer)
        onActivated: compass.openMenu(timerMenu)
    }
    leftAction {
        smallIcon: compass.camera.locks.exposureStatus == CameraLocks.Locked
                ? "image://theme/icon-camera-zoom-in?" + theme.highlightColor
                : "image://theme/icon-camera-zoom-in"
        largeIcon: "image://theme/icon-camera-zoom-tele"
        enabled: compass.buttonEnabled && !(settings.shootingModeProperties & Settings.Exposure)
        onActivated: {
            if (compass.camera.locks.exposureStatus == CameraLocks.Unlocked) {
                compass.camera.locks.lockExposure()
            } else {
                compass.camera.locks.unlockExposure()
            }
        }
    }
    rightAction {
        smallIcon: SettingsIcons.iso(settings.iso)
        largeIcon: "image://theme/icon-camera-iso"
        enabled: compass.buttonEnabled && !(settings.shootingModeProperties & Settings.Iso)
        onActivated: compass.openMenu(isoMenu)
    }

    icon: "image://theme/icon-camera-settings?" + theme.highlightColor

    Component {
        id: timerMenu

        CompassMenu {
            property: "timer"
            CompassMenuItem { value: 0; icon:  SettingsIcons.timer(0) }
            CompassMenuItem { value: 3; icon:  SettingsIcons.timer(3) }
            CompassMenuItem { value: 15; icon: SettingsIcons.timer(15) }
            CompassMenuItem { value: 20; icon: SettingsIcons.timer(20) }
        }
    }

    Component {
        id: exposureMenu

        CompassMenu {
            property: "exposureCompensation"
            CompassMenuItem { value: -4; icon: SettingsIcons.exposure(-4) }
            CompassMenuItem { value: -3; icon: SettingsIcons.exposure(-3) }
            CompassMenuItem { value: -2; icon: SettingsIcons.exposure(-2) }
            CompassMenuItem { value: -1; icon: SettingsIcons.exposure(-1) }
            CompassMenuItem { value: 0;  icon: SettingsIcons.exposure(0) }
            CompassMenuItem { value: 1;  icon: SettingsIcons.exposure(1) }
            CompassMenuItem { value: 2;  icon: SettingsIcons.exposure(2) }
            CompassMenuItem { value: 3;  icon: SettingsIcons.exposure(3) }
            CompassMenuItem { value: 4;  icon: SettingsIcons.exposure(4) }
        }
    }

    Component {
        id: isoMenu

        CompassMenu {
            property: "iso"
            CompassMenuItem { value: 0;    icon: SettingsIcons.iso(0) }
            CompassMenuItem { value: 100;  icon: SettingsIcons.iso(100) }
            CompassMenuItem { value: 200;  icon: SettingsIcons.iso(200) }
            CompassMenuItem { value: 400;  icon: SettingsIcons.iso(400) }
            CompassMenuItem { value: 800;  icon: SettingsIcons.iso(800) }
            CompassMenuItem { value: 1600; icon: SettingsIcons.iso(1600) }
        }
    }
}
