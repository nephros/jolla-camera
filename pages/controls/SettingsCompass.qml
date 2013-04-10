import QtQuick 1.2
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

Compass {
    property Camera camera

    northernIcon: "image://theme/icon-s-cloud-upload"
    westernIcon: "image://theme/icon-cover-subview"
    easternIcon: "image://theme/icon-cover-sync"
    southernIcon: "image://theme/icon-cover-new"
    centerIcon: "image://theme/icon-l-developer-mode"

    onNorthActivated: console.log("go north")
    onWestActivated: console.log("go west")
    onEastActivated: console.log("go east")
    onSouthActivated: console.log("go south")
}
