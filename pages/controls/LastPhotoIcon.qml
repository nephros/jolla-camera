import QtQuick 1.2
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import com.jolla.camera 1.0
import QtMobility.gallery 1.1
import org.nemomobile.thumbnailer 1.0

ClipArea {
    id: clipArea

    property Camera camera

    width: theme.itemSizeMedium
    height: theme.itemSizeMedium

    Repeater {
        model: DocumentGalleryModel {
            rootType: DocumentGallery.Image
            properties: ["url", "mimeType", "title", "dateTaken"]
            sortProperties: ["-dateTaken"]
            filter: GalleryStartsWithFilter { property: "filePath"; value: "/home/nemo/Pictures/Camera/" }
            limit: 1
            autoUpdate: true
        }

        Thumbnail {
            source: url
            width: clipArea.width
            height: clipArea.height
            sourceSize.width: clipArea.width
            sourceSize.height: clipArea.height
        }
    }

    MouseArea {
        width: clipArea.width
        height: clipArea.height
        onClicked: {
            if (camera.captureMode == Camera.Still) {
                galleryService.call("showPhotos", undefined)
            } else if (camera.captureMode == Camera.Video) {
                galleryService.call("showVideos", undefined)
            }
        }
    }

    DBusInterface {
        id: galleryService

        destination: "com.jolla.gallery"
        path: "/com/jolla/gallery/ui"
        iface: "com.jolla.gallery.ui"
    }
}
