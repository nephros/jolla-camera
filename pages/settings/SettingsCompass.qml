import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0
import "../compass"

Compass {
    id: compass

    property int timer: 0

    property Camera camera

    buttonEnabled: camera.captureMode == Camera.CaptureStillImage

    topAction {
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
        smallIcon: {
            switch (settings.timer) {
            case 0:
                return "image://theme/icon-camera-timer-off"
            case 3:
                return "image://theme/icon-camera-timer-3s"
            case 15:
                return "image://theme/icon-camera-timer-15s"
            case 20:
                return "image://theme/icon-camera-timer-20s"
            }
        }
        largeIcon: "image://theme/icon-camera-timer"
        enabled: compass.buttonEnabled && !(settings.shootingModeProperties & Settings.Timer)
        onActivated: compass.openMenu(timerMenu)
    }

    icon: "image://theme/icon-camera-settings?" + theme.highlightColor



    Component {
        id: timerMenu

        CompassMenu {
            property: "timer"
            CompassMenuItem {
                icon: "image://theme/icon-camera-timer-off"
                value: 0
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-timer-3s"
                value: 3
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-timer-15s"
                value: 15
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-timer-20s"
                value: 20
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
