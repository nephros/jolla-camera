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

    property Item page

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
        id: pageView

        x: -parent.x / 2
        width: galleryView.width
        height: galleryView.height

        pressDelay: 50
        boundsBehavior: Flickable.StopAtBounds
        cacheBuffer: width * 3

        orientation: ListView.Horizontal
        layoutDirection: Qt.RightToLeft
        snapMode: ListView.SnapOneItem
        highlightRangeMode: ListView.StrictlyEnforceRange

        interactive: !galleryView._playingState

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

            Component {
                id: imageComponent

                ZoomableImage {
                    source: url
                    onClicked: galleryView.split = !galleryView.split
                }
            }

            Component {
                id: videoComponent

                VideoItem {
                    player: video
                    active: galleryItem.active
                    source: url
                    mimeType: model.mimeType
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
