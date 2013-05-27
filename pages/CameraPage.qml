import QtQuick 1.2
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0
import QtMultimediaKit 1.1
import "capture"
import "settings"
import "gallery"

Page {
    id: page

    property bool windowActive
    property Item pageStack

    allowedOrientations: Orientation.Portrait | Orientation.Landscape

    /*
        This won't snap the header to position without modifiying Qt first.  There is an alternative
        mechanism which involves nesting ListViews which will work with a bleeding edge Qt but will
        cause the page to get stuck in the GalleryView on deployed versions.

        ListView {
            orientation: ListView.Horizontal
            layoutDirection: Qt.RightToLeft
            snapMode: ListView.SnapOneItem
            highlightRangeMode: ListView.StrictlyEnforceRange
            model: VisualItemModel {
                CaptureView {}
                GalleryView{}
            }
        }
    */

    GalleryView {
        id: galleryView

        width: page.width
        height: page.height

        page: page
        active: currentIndex != -1
        windowActive: page.windowActive
        orientation: page.orientation

        interactive: !captureView.menuOpen && !galleryView.menuOpen

        header: Item {
            // The ListView header item is sometimes destroyed and recreated by the ListView
            // in response to model and orientation changes.  We don't want that to ever happen to
            // the CaptureView so we make a placeholder header and anchor the real header to it.
            id: headerItem

            width: page.width
            height: page.height

            onParentChanged: {
                if (parent) {
                    captureView.anchors.left = headerItem.left
                }
            }
        }

        contentItem.children: CaptureView {
            id: captureView

            width: page.width
            height: page.height

            active: galleryView.currentIndex == -1

            orientation: page.orientation
            windowActive: page.windowActive
        }
    }
}

