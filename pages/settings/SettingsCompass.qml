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
        smallIcon: "image://theme/icon-camera-timer-off"
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

    icon: "image://theme/icon-camera-settings"

    Component {
        id: whiteBalanceMenu
        CompassMenu {
            //% "balance"
            title: qsTrId("camera-me-white-balance")
            CompassMenuItem {
                icon: "image://theme/icon-camera-wb-automatic"
                onClicked: settings.whiteBalance = CameraImageProcessing.WhiteBalanceAuto
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-wb-fluorecent"
                onClicked: settings.whiteBalance = CameraImageProcessing.WhiteBalanceFluorescent
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-wb-shade"
                onClicked: settings.whiteBalance = CameraImageProcessing.WhiteBalanceShade
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-wb-sunset"
                onClicked: settings.whiteBalance = CameraImageProcessing.WhiteBalanceSunset
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-wb-tungsten"
                onClicked: settings.whiteBalance = CameraImageProcessing.WhiteBalanceTungsten
            }
        }
    }

    Component {
        id: timerMenu

        CompassMenu {
            //% "seconds"
            title: qsTrId("camera-me-seconds")

            CompassMenuItem {
                icon: "image://theme/icon-camera-timer-3s"
                onClicked: compass.timer = 3
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-timer-15s"
                onClicked: compass.timer = 15
            }
            CompassMenuItem {
                icon: "image://theme/icon-camera-timer-20s"
                onClicked: compass.timer = 20
            }
        }
    }
}
