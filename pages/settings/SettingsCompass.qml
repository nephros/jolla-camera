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

    leftAction {
        smallIcon: "image://theme/icon-camera-wb-default"
        largeIcon: "image://theme/icon-camera-whitebalance"
        enabled: compass.buttonEnabled && !(settings.shootingModeProperties & Settings.WhiteBalance)
        onActivated: compass.openMenu(whiteBalanceMenu)
    }
    rightAction {
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
        enabled: compass.buttonEnabled
        onActivated: compass.openMenu(timerMenu)
    }

    icon: "image://theme/icon-camera-settings?" + theme.highlightColor

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
}
