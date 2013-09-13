import QtQuick 2.1
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import Sailfish.Gallery 1.0
import QtMultimedia 5.0
import com.jolla.camera 1.0

Drawer {
    id: galleryView

    readonly property bool interactive: active && (playing || (_activeItem && _activeItem.scaled))
    property bool active
    property bool windowActive
    property bool isPortrait
    property Item _activeItem

    property alias contentItem: pageView.contentItem
    property alias header: pageView.header
    property alias currentIndex: pageView.currentIndex

    property alias model: pageView.model

    property Item page

    readonly property bool playing: mediaPlayer.playbackState == MediaPlayer.PlayingState

    dock: isPortrait ? Dock.Top : Dock.Left

    onActiveChanged: {
        if (!active) {
            mediaPlayer.stop()
            mediaPlayer.source = ""
            pageView.currentIndex = -1
            open = false
        } else {
            pageView.currentIndex = 0
        }
        if (_activeItem) {
            _activeItem.active = active
        }
    }

    onWindowActiveChanged: {
        if (!windowActive && playing) {
            mediaPlayer.pause()
        }
    }

    ListView {
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
        highlightRangeMode: ListView.StrictlyEnforceRange

        interactive: !galleryView.menuOpen && pageView.count > 1

        onCurrentItemChanged: {
            if (!moving && currentItem) {
                if (galleryView._activeItem) {
                    galleryView._activeItem.active = false
                }

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
                galleryView._activeItem = currentItem
                if (galleryView._activeItem) {
                    galleryView._activeItem.active = true
                }
            }
        }

        delegate: Item {
            id: galleryItem

            property bool active
            readonly property QtObject modelData: model
            readonly property bool isImage: model.mimeType.indexOf("image/") == 0
            readonly property bool scaled: loader.item.scaled != undefined && loader.item.scaled

            width: galleryView.width
            height: galleryView.height
            clip: true

            Component {
                id: imageComponent

                ImageViewer {
                    source: url
                    onClicked: galleryView.open = !galleryView.open
                    fit: galleryView.isPortrait ? Fit.Width : Fit.Height
                    menuOpen: galleryView.opened

                    orientation: model.orientation
                }
            }

            Component {
                id: videoComponent

                VideoPoster {
                    player: mediaPlayer
                    active: galleryItem.active
                    source: url
                    mimeType: model.mimeType
                    duration: model.duration

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
                id: loader
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

                enabled: galleryView.count > 0

                onClicked: galleryView.open = !galleryView.open
            }
        ]

        contentItem.children: [
            GStreamerVideoOutput {
                id: video

                source: MediaPlayer {
                    id: mediaPlayer
                }

                visible: mediaPlayer.playbackState != MediaPlayer.StoppedState
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
