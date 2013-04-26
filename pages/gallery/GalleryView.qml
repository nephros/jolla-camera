import QtQuick 1.1
import Sailfish.Silica 1.0
import QtMobility.gallery 1.1
import QtMultimediaKit 1.1
import com.jolla.camera.settings 1.0
import "../views"

SplitItem {
    id: galleryView

    property bool menuOpen: galleryView.contracted || _playingState
    property bool active
    property bool windowActive
    property Item _activeItem

    property bool _playingState: video.playing && !video.paused

    dock: Dock.Right

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

    SilicaListView {
        x: -parent.x / 2
        width: galleryView.width
        height: galleryView.height

        pressDelay: 50
        boundsBehavior: Flickable.StopAtBounds

        orientation: ListView.Horizontal
        layoutDirection: Qt.RightToLeft
        snapMode: ListView.SnapOneItem
        highlightRangeMode: ListView.StrictlyEnforceRange

        interactive: !galleryView._playingState
        contentItem.enabled: !galleryView.contracted

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
                video.stop()
                video.source = ""
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

        delegate: MouseArea {
            id: galleryItem

            property bool isImage: mimeType.indexOf("image/") == 0
            property bool active

            width: galleryView.width
            height: galleryView.height

            Component {
                id: imageComponent

                ZoomableImage {
                    source: url
                }
            }

            Component {
                id: videoComponent

                VideoItem {
                    player: video
                    active: galleryItem.active
                    source: url
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

                onClicked: galleryView.split = !galleryView.split
            }
        ]

        contentItem.children: [
            Video {
                id: video

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
                width: galleryView.backgroundItem.width
                height: galleryView.backgroundItem.height
            }
        }
    ]
}
