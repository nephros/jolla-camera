import QtQuick 2.1
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import QtDocGallery 5.0
import QtMultimedia 5.0
import com.jolla.camera 1.0

Drawer {
    id: galleryView

    property bool menuOpen: galleryView.opened || _playingState
    property bool active
    property bool windowActive
    property int orientation
    property Item _activeItem

    readonly property bool empty: galleryModel.count == 0

    property alias contentItem: pageView.contentItem
    property alias header: pageView.header
    property bool interactive: true
    property alias currentIndex: pageView.currentIndex

    property Item page

    property bool _playingState: mediaPlayer.playbackState == MediaPlayer.PlayingState

    dock: orientation == Orientation.Portrait ? Dock.Top : Dock.Left

    onActiveChanged: {
        if (!active) {
            mediaPlayer.stop()
            mediaPlayer.source = ""
        }
        if (_activeItem) {
            _activeItem.active = active
        }
    }

    onWindowActiveChanged: {
        if (!windowActive && _playingState) {
            mediaPlayer.pause()
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

    SilicaListView {
        id: pageView

        x: -parent.x / 2
        y: -parent.y / 2
        width: galleryView.width
        height: galleryView.height

        pressDelay: 50
        boundsBehavior: Flickable.StopAtBounds
        cacheBuffer: width * 3

        orientation: ListView.Horizontal
        layoutDirection: Qt.RightToLeft
        snapMode: ListView.SnapOneItem
        highlightRangeMode: ListView.StrictlyEnforceRange

        interactive: !galleryView._playingState && galleryView.interactive && galleryModel.count > 0

        onCurrentItemChanged: {
            if (!galleryView._activeItem && currentItem) {
                galleryView._activeItem = currentItem
                galleryView._activeItem.active = true
            }
        }

        onMovingChanged: {
            if (!moving && galleryView._activeItem != currentItem) {
                if (galleryView._activeItem) {
                    galleryView._activeItem.active = false
                }
                mediaPlayer.stop()
                mediaPlayer.source = ""
                video.visible = false
                galleryView._activeItem = currentItem
                if (galleryView._activeItem) {
                    galleryView._activeItem.active = true
                }
            }
        }

        model: DocumentGalleryModel {
            id: galleryModel
            rootType: DocumentGallery.File
            properties: [ "url", "mimeType", "title", "dateTaken" ]
            sortProperties: ["-dateTaken"]
            autoUpdate: true
            filter: GalleryFilterUnion {
                GalleryEqualsFilter { property: "path"; value: Settings.photoDirectory }
                GalleryEqualsFilter { property: "path"; value: Settings.videoDirectory }
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
                    player: mediaPlayer
                    active: galleryItem.active
                    source: url
                    mimeType: model.mimeType

                    onClicked: {
                        if (mediaPlayer.playbackState == MediaPlayer.PlayingState) {
                            mediaPlayer.pause()
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

                enabled: galleryModel.count > 0

                onClicked: galleryView.open = !galleryView.open
            }
        ]

        contentItem.children: [
            GStreamerVideoOutput {
                id: video

                source: MediaPlayer {
                    id: mediaPlayer
                    property alias visible: video.visible
                }

                visible: false
                width: galleryView.width
                height: galleryView.height
                anchors.centerIn: galleryView._activeItem
            }
        ]
    }

    background: [
        Loader {
            asynchronous: true

            ShareMenu {
                page: galleryView.page

                width: galleryView.backgroundItem.width
                height: galleryView.backgroundItem.height

                title: pageView.currentItem ? pageView.currentItem.modelData.title : ""
                filter: pageView.currentItem ? pageView.currentItem.modelData.mimeType : ""
                isImage: pageView.currentItem ? pageView.currentItem.isImage : false
                url: pageView.currentItem ? pageView.currentItem.modelData.url : ""
            }
        }
    ]
}
