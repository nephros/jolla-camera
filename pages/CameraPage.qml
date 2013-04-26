import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0
import QtMultimediaKit 1.1
import "capture"
import "settings"
import "gallery"
import "views"

Page {
    id: page

    property bool windowActive

    allowedOrientations: Orientation.Landscape

    SilicaListView {
        id: listView

        width: page.width
        height: page.height

        orientation: ListView.Horizontal
        layoutDirection: Qt.RightToLeft
        snapMode: ListView.SnapOneItem
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightMoveDuration: 500

        interactive: !captureView.menuOpen && !galleryView.menuOpen

        model: VisualItemModel {
            CaptureView {
                id: captureView

                width: page.width
                height: page.height
                active: !listView.atXBeginning
                windowActive: page.windowActive

                onOpenCameraRoll: {
                    listView.currentIndex = 1
                }
            }
            GalleryView {
                id: galleryView

                width: page.width
                height: page.height
                active: !listView.atXEnd
                windowActive: page.windowActive
            }
        }
    }
}
