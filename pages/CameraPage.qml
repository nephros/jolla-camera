import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import QtDocGallery 5.0
import QtMultimedia 5.0
import "capture"
import "settings"
import "gallery"

Page {
    id: page

    property bool windowActive
    property Item pageStack

    allowedOrientations: Orientation.Portrait | Orientation.Landscape

    ListView {
        width: page.width
        height: page.height

        orientation: ListView.Horizontal
        layoutDirection: Qt.RightToLeft
        snapMode: ListView.SnapOneItem
        boundsBehavior: Flickable.StopAtBounds
        highlightRangeMode: ListView.StrictlyEnforceRange
        interactive: !captureView.menuOpen && !galleryView.menuOpen && galleryModel.count > 0
        model: VisualItemModel {
            CaptureView {
                id: captureView

                width: page.width
                height: page.height

                active: true

                orientation: page.orientation
                windowActive: page.windowActive

                camera.imageCapture.onImageSaved: {
                    captureModel.prependCapture(path, "image/jpeg", camera.extensions.orientation)
                }

                onRecordingStopped: {
                    captureModel.prependCapture(url, mimeType, camera.extensions.orientation)
                }
            }

            GalleryView {
                id: galleryView

                width: page.width
                height: page.height

                page: page
                model: captureModel
                active: false
                windowActive: page.windowActive
                isPortrait: page.orientation == Orientation.Portrait
                            || page.orientation == Orientation.PortraitInverted
            }
        }

        onMovingChanged: {
            if (!moving) {
                galleryView.active = galleryView.ListView.isCurrentItem
                captureView.active = captureView.ListView.isCurrentItem
            }
        }
    }

    CaptureModel {
        id: captureModel

        source: DocumentGalleryModel {
            id: galleryModel
            rootType: DocumentGallery.File
            properties: [ "url", "title", "mimeType", "orientation" ]
            sortProperties: ["-fileName"]
            autoUpdate: true
            filter: GalleryFilterUnion {
                GalleryEqualsFilter { property: "path"; value: Settings.photoDirectory }
                GalleryEqualsFilter { property: "path"; value: Settings.videoDirectory }
            }
        }
    }
}

