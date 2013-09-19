import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0
import "../compass"
import "SettingsIcons.js" as SettingsIcons

Compass {
    id: compass

    property int timer: 0

    property Camera camera

    interactive: camera.captureMode == Camera.CaptureStillImage
    keepSelection: camera.locks.focusStatus == CameraLocks.Searching
                || camera.locks.exposureStatus == CameraLocks.Searching

    topAction {
        smallIcon: SettingsIcons.exposure(Settings.mode.exposureCompensation)
        largeIcon: "image://theme/icon-camera-exposure-compensation"
        enabled: Settings.mode.exposureConfigurable
        onActivated: compass.openMenu(exposureMenu)
    }
    bottomAction {
        smallIcon: SettingsIcons.timer(Settings.mode.timer)
        largeIcon: "image://theme/icon-camera-timer"
        // ### Timer UI is disabled until design is finalized and the feature is implemented.
        // JB#1222
        enabled: false && Settings.mode.timerConfigurable
        onActivated: compass.openMenu(timerMenu)
    }
    leftAction {
        smallIcon: compass.camera.locks.exposureStatus == CameraLocks.Locked
                ? "image://theme/icon-camera-zoom-in?" + Theme.highlightColor
                : "image://theme/icon-camera-zoom-in"
        largeIcon: "image://theme/icon-camera-zoom-tele"
        enabled: Settings.mode.exposureConfigurable
        onActivated: {
            if (compass.camera.locks.exposureStatus == CameraLocks.Unlocked) {
                compass.camera.locks.lockExposure()
            } else {
                compass.camera.locks.unlockExposure()
            }
        }
    }
    rightAction {
        smallIcon: SettingsIcons.iso(Settings.mode.iso)
        largeIcon: "image://theme/icon-camera-iso"
        enabled: Settings.mode.isoConfigurable
        onActivated: compass.openMenu(isoMenu)
    }

    Image {
        id: settingsIcon
        anchors.centerIn: parent
        source: "image://theme/icon-camera-settings?" + Theme.highlightColor
        opacity: compass.interactive ? 1 : 0
        Behavior on  opacity { FadeAnimation {} }
    }

    Label {
        anchors.centerIn: parent
        opacity: 1 - settingsIcon.opacity
        text: Format.formatDuration(compass.camera.videoRecorder.duration / 1000, Formatter.DurationLong)
        font.pixelSize: Theme.fontSizeExtraSmall
    }


    Component {
        id: timerMenu

        CompassMenu {
            settings: Settings.mode
            property: "timer"
            model: [ 0, 3, 15, 20 ]
            delegate: CompassMenuItem { value: modelData; icon: SettingsIcons.timer(modelData) }
        }
    }

    Component {
        id: exposureMenu

        CompassMenu {
            settings: Settings.mode
            property: "exposureCompensation"
            model: [ -4, -3, -2, -1, 0, 1, 2, 3, 4 ]
            delegate: CompassMenuItem { value: modelData; icon: SettingsIcons.exposure(modelData) }
        }
    }

    Component {
        id: isoMenu

        CompassMenu {
            settings: Settings.mode
            property: "iso"
            model: [ 0, 100, 200, 400, 800, 1600 ]
            delegate: CompassMenuItem { value: modelData; icon: SettingsIcons.iso(modelData) }
        }
    }
}
