import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0
import org.nemomobile.time 1.0
import "../compass"

Compass {
    id: compass

    property int timer: 0

    property Camera camera

    property var _startTime: new Date()
    property var _endTime: _startTime

    interactive: camera.captureMode == Camera.CaptureStillImage
    keepSelection: camera.locks.focusStatus == CameraLocks.Searching
                || camera.locks.exposureStatus == CameraLocks.Searching

    onClicked: if (settingsIcon.enabled) { compass.openMenu(focusMenu) }

    topAction {
        smallIcon: Settings.exposureIcon(Settings.mode.exposureCompensation)
        largeIcon: "image://theme/icon-camera-exposure-compensation"
        enabled: Settings.mode.exposureConfigurable
        onActivated: compass.openMenu(exposureMenu)
    }
    bottomAction {
        smallIcon: Settings.timerIcon(Settings.mode.timer)
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
        smallIcon: Settings.isoIcon(Settings.mode.iso)
        largeIcon: "image://theme/icon-camera-iso"
        enabled: Settings.mode.isoConfigurable
        onActivated: compass.openMenu(isoMenu)
    }

    Image {
        id: settingsIcon
        anchors.centerIn: parent
        source: Settings.focusDistanceIcon(Settings.mode.focusDistance) + "?" + Theme.highlightColor
        enabled: compass.interactive && Settings.mode.focusDistanceConfigurable
        opacity: enabled ? 1 : 0
        Behavior on  opacity { FadeAnimation {} }
    }

    Label {
        anchors.centerIn: parent
        text: Format.formatDuration(
                  ((clock.enabled ? clock.time : compass._endTime) - compass._startTime) / 1000,
                  Formatter.DurationLong)
        font.pixelSize: Theme.fontSizeExtraSmall
        opacity: compass.interactive ? 0 : 1
        Behavior on  opacity { FadeAnimation {} }
    }

    WallClock {
        id: clock
        updateFrequency: WallClock.Second
        enabled: camera.videoRecorder.recorderState == CameraRecorder.RecordingState
        onEnabledChanged: {
            if (enabled) {
                compass._startTime = clock.time
                compass._endTime = compass._startTime
            } else {
                compass._endTime = compass._startTime
            }
        }
    }

    Component {
        id: timerMenu

        CompassMenu {
            settings: Settings.mode
            property: "timer"
            model: [ 0, 3, 15, 20 ]
            delegate: CompassMenuItem { value: modelData; icon: Settings.timerIcon(modelData) }
        }
    }

    Component {
        id: exposureMenu

        CompassMenu {
            settings: Settings.mode
            property: "exposureCompensation"
            model: [ -4, -3, -2, -1, 0, 1, 2, 3, 4 ]
            delegate: CompassMenuItem { value: modelData; icon: Settings.exposureIcon(modelData) }
        }
    }

    Component {
        id: isoMenu

        CompassMenu {
            settings: Settings.mode
            property: "iso"
            model: [ 0, 100, 200, 400, 800, 1600 ]
            delegate: CompassMenuItem { value: modelData; icon: Settings.isoIcon(modelData) }
        }
    }

    Component {
        id: focusMenu

        CompassMenu {
            settings: Settings.mode
            property: "focusDistance"
            model: [ Camera.FocusAuto, Camera.FocusInfinity, Camera.FocusMacro ]
            delegate: CompassMenuItem { value: modelData; icon: Settings.focusDistanceIcon(modelData) }
        }
    }
}
