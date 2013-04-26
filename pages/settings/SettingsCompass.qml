import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0
import "../compass"

Compass {
    id: compass

    property Camera camera

    property int zoomIndex: 0
    onZoomIndexChanged: camera.digitalZoom = _zoomLevels[zoomIndex]
    property variant _zoomLevels: [ 1, 1.5, 2, 2.5, 3, 4, 6, 8, 10, 12, 16 ]

    buttonEnabled: camera.captureMode == Camera.CaptureStillImage

    north {
        smallIcon: "image://theme/icon-s-cloud-upload"
        largeIcon: "image://theme/icon-s-cloud-upload"
        enabled: camera.digitalZoom < camera.maximumDigitalZoom
                    && compass.zoomIndex < compass._zoomLevels.length
        onActivated: ++compass.zoomIndex
    }
    west {
        smallIcon: "image://theme/icon-cover-subview"
        largeIcon: "image://theme/icon-cover-subview"
        enabled: compass.buttonEnabled && !(settings.shootingModeProperties & Settings.WhiteBalance)
        onActivated: console.log("go west")
    }
    east {
        smallIcon: "image://theme/icon-m-timer"
        largeIcon: "image://theme/icon-cover-timer"
        enabled: compass.buttonEnabled
        onActivated: compass.openMenu(timerMenu)
    }
    south {
        smallIcon: "image://theme/icon-cover-new"
        largeIcon: "image://theme/icon-cover-new"
        enabled: camera.digitalZoom > 1.0 && compass.zoomIndex > 0
        onActivated: --compass.zoomIndex
    }

    icon: "image://theme/icon-m-developer-mode"

    Component {
        id: timerMenu

        CompassMenu {
            //% "seconds"
            title: qsTrId("camera-me-seconds")

            CompassMenuText { label: "3"; onClicked: console.log("3 second timer") }
            CompassMenuText { label: "5"; onClicked: console.log("5 second timer"); }
            CompassMenuText { label: "12"; onClicked: console.log("12 second timer"); }
            CompassMenuText { label: "20"; onClicked: console.log("20 second timer"); }
        }
    }
}
