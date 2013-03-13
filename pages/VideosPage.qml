import QtQuick 1.1
import Sailfish.Silica 1.0
import QtMobility.gallery 1.1
import org.nemomobile.thumbnailer 1.0
import "controls"

PreviewPage {
    id: page

    model: DocumentGalleryModel {
        // How to identify videos from the camera?
        rootType: DocumentGallery.Video
        properties: [ "url", "title", "mimeType" ]
        sortProperties: ["-dateTaken"]
    }

    delegate: Thumbnail {
        property url url: model.url
        property string title: model.title
        property string mimeType: model.mimeType

        width: page.width
        height: page.height

        sourceSize.width: screen.height
        sourceSize.height: screen.height

        source: model.url
        fillMode: Thumbnail.PreserveAspectFit

        MouseArea {
            anchors.fill: parent
            onClicked: page.toggleSplit()
        }
    }

    menus: [
        //: Video preview menu
        PullDownMenu {
            MenuItem {
                //% "Delete"
                text: qsTrId("camera-me-delete-video")
            }
            MenuItem {
                //% "Open in Gallery"
                text: qsTrId("camera-me-open-video")
            }
        }
    ]
}
