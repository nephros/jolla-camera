import QtQuick 2.1
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import Sailfish.Gallery 1.0
import QtMultimedia 5.0
import com.jolla.camera 1.0
import ".."

Drawer {
    id: galleryView

    readonly property bool positionLocked: active && _activeItem && _activeItem.scaled
    readonly property bool active: page.galleryActive
    readonly property bool windowActive: page.windowActive
    property Item _activeItem

    property alias contentItem: pageView.contentItem
    property alias header: pageView.header
    property alias currentIndex: pageView.currentIndex

    property alias model: pageView.model

    property CameraPage page

    readonly property bool playing: mediaPlayer.playbackState == MediaPlayer.PlayingState
    readonly property bool _transposeVideo: page.isPortrait ^ (video.implicitHeight > video.implicitWidth)

    function positionViewAtBeginning() {
        pageView.currentIndex = pageView.count - 1
        pageView.positionViewAtEnd()
    }

    dock: page.isPortrait ? Dock.Top : Dock.Left

    onActiveChanged: {
        if (!active) {
            mediaPlayer.stop()
            mediaPlayer.source = ""
            open = false
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

    Component.onCompleted: positionViewAtBeginning()

    ListView {
        id: pageView

        x: -parent.x / 2
        y: -parent.y / 2
        width: galleryView.width
        height: galleryView.height

        boundsBehavior: Flickable.StopAtBounds
        cacheBuffer: width

        snapMode: ListView.SnapOneItem
        highlightRangeMode: ListView.StrictlyEnforceRange

        orientation: ListView.Horizontal
        currentIndex: count - 1
        pressDelay: 0

        interactive: pageView.count > 1 && !galleryView.positionLocked

        onCurrentItemChanged: {
            if (!moving && currentItem) {
                if (galleryView._activeItem) {
                    galleryView._activeItem.active = false
                }

                galleryView._activeItem = currentItem
                galleryView._activeItem.active = true
            }
        }

        onCurrentIndexChanged: {
            if (!moving) {
                // ListView's item positioning and currentIndex can get out of sync
                // when items are removed from and possibly when inserted into the
                // model.  Finding and fixing all the corner cases in ListView is a
                // bit of a battle so as a final safeguard, we force the position to
                // update if anything other than flicking the list changes the current
                // index.
                positionViewAtIndex(currentIndex, ListView.SnapPosition)
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
            readonly property int index: model.index
            readonly property string title: model.title
            readonly property string mimeType: model.mimeType
            readonly property url url: model.url

            readonly property bool isImage: mimeType.indexOf("image/") == 0
            readonly property bool scaled: loader.item && loader.item.scaled

            width: galleryView.width
            height: galleryView.height
            clip: true

            Component {
                id: imageComponent

                ImageViewer {
                    source: url
                    onClicked: galleryView.open = !galleryView.open
                    fit: galleryView.page.isPortrait ? Fit.Width : Fit.Height
                    menuOpen: galleryView.opened
                    enableZoom: !pageView.moving

                    orientation: model.orientation
                    maximumWidth: model.width
                    maximumHeight: model.height

                    active: galleryItem.active
                }
            }

            Component {
                id: videoComponent

                VideoPoster {
                    property bool scaled: false

                    player: mediaPlayer
                    active: galleryItem.active
                    source: url
                    mimeType: model.mimeType
                    duration: model.duration

                    transpose: galleryView.page.isPortrait ^ (implicitHeight > implicitWidth)

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

                enabled: pageView.count > 0

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
                width: !galleryView._transposeVideo ? galleryView.width : galleryView.height
                height: !galleryView._transposeVideo ? galleryView.height : galleryView.width
                anchors.centerIn: galleryView._activeItem

                rotation: galleryView._transposeVideo
                        ? (video.implicitHeight > video.implicitWidth ? 270 : 90)
                        : 0
            }
        ]
    }

    background: [
        ShareMenu {
            page: galleryView.page

            width: galleryView.backgroundItem.width
            height: galleryView.backgroundItem.height

            title: pageView.currentItem ? pageView.currentItem.title : ""
            filter: pageView.currentItem ? pageView.currentItem.mimeType : ""
            isImage: pageView.currentItem ? pageView.currentItem.isImage : false
            source: pageView.currentItem ? pageView.currentItem.url : ""

            onDeleteFile: {
                var remorse = remorseComponent.createObject(galleryView)
                var item = pageView.currentItem
                item.ListView.delayRemove = true
                //: Deleting photo or video in 5 seconds
                //% "Deleting"
                remorse.execute(item, qsTrId("camera-la-deleting"), function() {
                    item.ListView.delayRemove = false
                    galleryView.model.deleteFile(item.index)
                    remorse.destroy(1)
                })
            }
        }
    ]

    Component {
        id: remorseComponent

        Item {
            id: wrapper

            x: 0
            y: -pageView.y
            width: parent.width
            height: Theme.itemSizeSmall

            function execute(item, label, callback) {
                parent = item
                remorse.execute(positioner, label, callback)
            }

            Rectangle {
                color: Theme.highlightDimmerColor
                opacity: 0.6
                anchors.fill: parent
            }

            Item {
                id: positioner
                anchors.fill: parent
            }

            RemorseItem {
                id: remorse

                onCanceled: {
                    wrapper.destroy(1)
                }
            }
        }
    }
}
