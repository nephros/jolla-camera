import QtQuick 2.1
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import QtDocGallery 5.0
import com.jolla.camera 1.0
import "pages"
import "cover"

ApplicationWindow {
    id: window

    property QtObject _window
    property alias captureModel: captureModelItem
    property bool galleryActive
    property int galleryIndex

    onWindowChanged: _window = window ? window : null
    allowedOrientations: defaultAllowedOrientations
    _defaultPageOrientations: Orientation.All
    _defaultLabelFormat: Text.PlainText

    cover: Component{
        CameraCover {
        }
    }

    initialPage: Component {
        CameraPage {
            id: cameraPage

            pageStack: window.pageStack
            windowVisible: window._window && window._window.visible
            viewfinder: videoOutput
        }
    }

    Rectangle {
        anchors.fill: videoOutput
        z: -1
        color: "black"
    }

    GStreamerVideoOutput {
        id: videoOutput

        z: -1
        width: window.width
        height: window.height
    }

    CaptureModel {
        id: captureModelItem

        source: DocumentGalleryModel {
            rootType: DocumentGallery.File
            properties: [ "url", "title", "mimeType", "orientation", "duration", "width", "height" ]
            sortProperties: ["fileName"]
            autoUpdate: true
            filter: GalleryFilterUnion {
                GalleryEqualsFilter { property: "path"; value: Settings.photoDirectory }
                GalleryEqualsFilter { property: "path"; value: Settings.videoDirectory }
            }
        }
    }

    onApplicationActiveChanged:
        if (applicationActive)
            Settings.updateLocation()
}
