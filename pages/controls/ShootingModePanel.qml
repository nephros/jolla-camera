import QtQuick 1.2
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

DockedPanel {
    id: panel

    width: parent.width
    height: theme.itemSizeExtraLarge

    property Camera camera
    property ShootingModeItem currentItem: manualMode
    property url currentIcon: currentItem.icon + "?" + theme.highlightColor

    Row {
        height: panel.height
        anchors.centerIn: parent

        ShootingModeItem {
            id: manualMode
            icon: "image://theme/icon-cover-cancel"
            onClicked: {
                console.log("manual mode")
            }
        }
        ShootingModeItem {
            id: programMode
            icon: "image://theme/icon-cover-play"
            onClicked: {
                console.log("program mode")
            }

        }
        ShootingModeItem {
            id: apertureMode
            icon: "image://theme/icon-cover-sync"
            onClicked: {
                console.log("aperture mode")
            }
        }
        ShootingModeItem {
            id: sportsMode
            icon: "image://theme/icon-cover-shuffle"
            onClicked: {
                console.log("sports mode")
            }
        }
        ShootingModeItem {
            id: macroMode
            icon: "image://theme/icon-cover-new"
            onClicked: {
                console.log("macro mode")
            }
        }
        ShootingModeItem {
            id: nightPortraitMode
            icon: "image://theme/icon-cover-favorite"
            onClicked: {
                console.log("night portrait mode")
            }
        }
        ShootingModeItem {
            id: portraitMode
            icon: "image://theme/icon-cover-people"
            onClicked: {
                console.log("portrait mode")
            }
        }
    }
}
