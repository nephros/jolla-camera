import QtQuick 1.1
import Sailfish.Silica 1.0
import QtMobility.gallery 1.1
import "controls"

PreviewPage {
    id: page

    model: DocumentGalleryModel {
        // How to identify photos from the camera?
        rootType: DocumentGallery.Image
        properties: [ "url", "title", "mimeType" ]
        sortProperties: ["-dateTaken"]
    }

    delegate: Image {
        property url url: model.url
        property string title: model.title
        property string mimeType: model.mimeType

        width: page.width
        height: page.height

        sourceSize.width: screen.height

        source: model.url
        fillMode: Image.PreserveAspectFit

        MouseArea {
            anchors.fill: parent
            onClicked: page.toggleSplit()
        }
    }

    menus: [
        PullDownMenu {
            //: Photo preview menu
            MenuItem {
                //% "Delete"
                text: qsTrId("camera-me-delete-photo")
            }
            MenuItem {
                //% "Open in Gallery"
                text: qsTrId("camera-me-open-photo")
            }
        }
    ]
}
