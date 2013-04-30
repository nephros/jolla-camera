import QtQuick 1.1
import Sailfish.Silica 1.0

SilicaListView {
    PullDownMenu {
        id: pullDownMenu
        MenuItem {
            //% "Details"
            text: qsTrId("camera-me-details")
        }

        MenuItem {
            //% "Delete"
            text: qsTrId("camera-me-delete")
        }

        MenuItem {
            //% "Create ambience"
            text: qsTrId("gallery-me-create_ambience")
        }
    }
}
