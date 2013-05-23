import QtQuick 1.1
import Sailfish.Silica 1.0
import QtMobility.gallery 1.1
import QtMultimediaKit 1.1
import com.jolla.camera.settings 1.0

Drawer {
    id: galleryView

    property bool menuOpen: galleryView.opened || _playingState
    property bool active
    property bool windowActive
    property int orientation
    property Item _activeItem

    property alias contentItem: pageView.contentItem
    property alias header: pageView.header
    property bool interactive: true
    property alias currentIndex: pageView.currentIndex

    property Item page

    property bool _playingState: video.playing && !video.paused

    dock: orientation == Orientation.Portrait ? Dock.Top : Dock.Left

    onActiveChanged: {
        if (!active) {
            video.stop()
            video.source = ""
        }
        if (_activeItem) {
            _activeItem.active = active
        }
    }

    onWindowActiveChanged: {
        if (!windowActive && _playingState) {
            video.pause()
        }
    }

    // ListView doesn't handle header alignment as well as it possibly could when the rotation
    // changes.  Ensure the item that is currently visible remains visible when on rotation.
    onOrientationChanged: {
        if (pageView.currentIndex == -1) {
            pageView.positionViewAtBeginning()
        } else {
            pageView.positionViewAtIndex(pageView.currentIndex, ListView.Center)
        }
    }

    Formatter {
        id: durationFormatter
    }

    SilicaListView {
        id: pageView

        x: -parent.x / 2
        y: -parent.y / 2
        width: galleryView.width
        height: galleryView.height

        pressDelay: 50
        boundsBehavior: Flickable.StopAtBounds
        cacheBuffer: width * 3
        currentIndex: -1

        orientation: ListView.Horizontal
        layoutDirection: Qt.RightToLeft
        snapMode: ListView.SnapOneItem

        interactive: !galleryView._playingState && galleryView.interactive

        onCurrentItemChanged: {
            if (!galleryView._activeItem && currentItem) {
                galleryView._activeItem = currentItem
                galleryView._activeItem.active = true
            }
        }

        onMovingChanged: {
            // ListView.StrictlyEnforceRange prevents snapping to the the header, so we update the
            // currentIndex ourselves.
            currentIndex = indexAt(contentX + width / 2, contentY + height / 2)
            console.log("current index is", currentIndex)
            if (!moving && galleryView._activeItem != currentItem) {
                if (galleryView._activeItem) {
                    galleryView._activeItem.active = false
                }
                video.stop()
                video.source = ""
                video.visible = false
                galleryView._activeItem = currentItem
                if (galleryView._activeItem) {
                    galleryView._activeItem.active = true
                }
            }
        }

        model: DocumentGalleryModel {
            rootType: DocumentGallery.File
            properties: [ "url", "mimeType", "title", "dateTaken" ]
            sortProperties: ["-dateTaken"]
            autoUpdate: true
            filter: GalleryFilterUnion {
                GalleryEqualsFilter { property: "path"; value: settings.photoDirectory }
                GalleryEqualsFilter { property: "path"; value: settings.videoDirectory }
            }
        }

        delegate: Item {
            id: galleryItem

            property QtObject modelData: model
            property bool isImage: mimeType.indexOf("image/") == 0
            property bool active

            width: galleryView.width
            height: galleryView.height
            clip: true

            Component {
                id: imageComponent

                ZoomableImage {
                    source: url
                    onClicked: galleryView.open = !galleryView.open
                    isPortrait: galleryView.orientation == Orientation.Portrait
                    menuOpen: galleryView.opened
                }
            }

            Component {
                id: videoComponent

                VideoItem {
                    player: video
                    active: galleryItem.active
                    source: url
                    mimeType: model.mimeType
                    formatter: durationFormatter

                    onClicked: {
                        if (video.playing && !video.paused) {
                            video.pause()
                        } else {
                            galleryView.open = !galleryView.open
                        }
                    }
                }
            }

            Loader {
                width: galleryItem.width
                height: galleryItem.height

                sourceComponent: galleryItem.isImage ? imageComponent: videoComponent
            }
        }

        children: [
            MouseArea {
                z: -1
                width: galleryView.width
                height: galleryView.height

                onClicked: galleryView.open = !galleryView.open
            }
        ]

        contentItem.children: [
            Video {
                id: video

                visible: false
                width: galleryView.width
                height: galleryView.height
                anchors.centerIn: galleryView._activeItem

                fillMode: Video.PreserveAspectFit
            }
        ]
    }

    background: [
        Loader {
//            asynchronous: true

            ShareMenu {
                page: galleryView.page

                width: galleryView.backgroundItem.width
                height: galleryView.backgroundItem.height

                title: pageView.currentItem ? pageView.currentItem.modelData.title : ""
                filter: pageView.currentItem ? pageView.currentItem.modelData.mimeType : ""
                isImage: pageView.currentItem ? pageView.currentItem.isImage : ""
            }
        }
    ]
}
