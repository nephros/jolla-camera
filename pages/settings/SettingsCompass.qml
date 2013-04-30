import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0
import "../compass"

Compass {
    id: compass

    property int timer: 0

    property Camera camera

    property int zoomIndex: 0
    onZoomIndexChanged: camera.digitalZoom = _zoomLevels[zoomIndex]
    property variant _zoomLevels: [ 1, 1.5, 2, 2.5, 3, 4, 6, 8, 10, 12, 16 ]

    buttonEnabled: camera.captureMode == Camera.CaptureStillImage

    topAction {
        smallIcon: "image://theme/icon-camera-zoom-in"
        largeIcon: "image://theme/icon-camera-zoom-tele"
        enabled: camera.digitalZoom < camera.maximumDigitalZoom
                    && compass.zoomIndex < compass._zoomLevels.length
        onActivated: ++compass.zoomIndex
    }
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
    bottomAction {
        smallIcon: "image://theme/icon-camera-zoom-out"
        largeIcon: "image://theme/icon-camera-zoom-wide"
        enabled: camera.digitalZoom > 1.0 && compass.zoomIndex > 0
        onActivated: --compass.zoomIndex
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
