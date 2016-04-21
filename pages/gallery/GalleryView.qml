import QtQuick 2.1
import QtQml.Models 2.1
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import Sailfish.Gallery 1.0
import QtMultimedia 5.0
import QtDocGallery 5.0
import com.jolla.camera 1.0
import org.nemomobile.policy 1.0
import ".."

Drawer {
    id: galleryView

    readonly property bool positionLocked: active && _activeItem && _activeItem.scaled
    readonly property bool active: page.galleryActive
    readonly property bool windowActive: page.windowVisible
    property Item _activeItem
    property alias _videoActive: permissions.enabled
    property bool _minimizedPlaying

    property alias contentItem: pageView.contentItem
    property alias header: pageView.header
    property alias currentIndex: pageView.currentIndex

    property alias model: delegateModel.model

    property alias captureModel: captureModelItem

    property CameraPage page

    readonly property bool playing: mediaPlayer.playbackState == MediaPlayer.PlayingState

    property int _preOrientationChangeIndex

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
        if (!windowActive) {
            // if we were playing a video when we minimized, store that information.
            _minimizedPlaying = playing
            if (_minimizedPlaying) {
                mediaPlayer.pause() // and automatically pause the video
            }
        } else if (_minimizedPlaying) {
            _play() // restart playback automatically.  will also go fullscreen.
        }
    }

    function _play() {
        if (_videoActive) {
            mediaPlayer.source = galleryView._activeItem.url
            mediaPlayer.play()
        }
    }

    function _togglePlay() {
        if (mediaPlayer.playbackState == MediaPlayer.PlayingState) {
            mediaPlayer.pause()
        } else if (_videoActive) {
            mediaPlayer.source = galleryView._activeItem.url
            mediaPlayer.play()
        }
    }

    function _pause() {
        if (_videoActive) {
            mediaPlayer.source = galleryView._activeItem.url
            mediaPlayer.pause()
        }
    }

    function _stop() {
        mediaPlayer.stop()
    }

    CaptureModel {
        id: captureModelItem

        source: DocumentGalleryModel {
            id: galleryModel

            property bool populated

            rootType: DocumentGallery.File
            properties: [ "url", "title", "mimeType", "orientation", "duration", "width", "height" ]
            sortProperties: ["fileName"]
            autoUpdate: true
            filter: GalleryFilterUnion {
                GalleryEqualsFilter { property: "path"; value: Settings.photoDirectory }
                GalleryEqualsFilter { property: "path"; value: Settings.videoDirectory }
            }
            onStatusChanged: {
                if (status === DocumentGalleryModel.Finished) {
                    populated = true
                    positionViewAtBeginning()
                }
            }
        }
    }

    MediaKey { enabled: keysResource.acquired; key: Qt.Key_MediaTogglePlayPause; onPressed: galleryView._togglePlay() }
    MediaKey { enabled: keysResource.acquired; key: Qt.Key_MediaPlay; onPressed: galleryView._play() }
    MediaKey { enabled: keysResource.acquired; key: Qt.Key_MediaPause; onPressed: galleryView._pause() }
    MediaKey { enabled: keysResource.acquired; key: Qt.Key_MediaStop; onPressed: galleryView._stop() }
    MediaKey { enabled: keysResource.acquired; key: Qt.Key_ToggleCallHangup; onPressed: galleryView._togglePlay() }

    Permissions {
        id: permissions

        enabled: galleryView.active && galleryView._activeItem && !galleryView._activeItem.isImage
        applicationClass: "player"

        Resource {
            id: keysResource
            type: Resource.HeadsetButtons
            optional: true
        }
    }

    DelegateModel {
        id: delegateModel

        model: captureModel

        delegate: Item {
            id: galleryItem

            property bool active
            readonly property variant itemId: model.itemId
            readonly property int index: model.index
            readonly property string title: model.title
            readonly property string mimeType: model.mimeType
            readonly property url url: model.url
            readonly property bool resolved: model.resolved

            readonly property bool isImage: mimeType.indexOf("image/") == 0
            readonly property bool scaled: loader.item && loader.item.scaled

            width: pageView.width
            height: pageView.height
            clip: true

            Component {
                id: imageComponent

                ImageViewer {
                    width: galleryView.width
                    height: galleryView.height

                    source: url
                    onClicked: galleryView.open = !galleryView.open
                    fit: galleryView.page.isPortrait ? Fit.Width : Fit.Height
                    menuOpen: galleryView.open
                    enableZoom: !pageView.moving

                    orientation: model.orientation

                    active: galleryItem.active
                }
            }

            Component {
                id: videoComponent

                VideoPoster {
                    property bool scaled: false

                    width: galleryItem.width
                    height: galleryItem.height

                    contentWidth: galleryView.width
                    contentHeight: galleryView.height

                    player: mediaPlayer
                    active: galleryItem.active
                    source: url
                    mimeType: model.mimeType
                    duration: model.duration

                    onClicked: {
                        galleryView.open = !galleryView.open
                        if (galleryView.playing) {
                            // pause and go splitscreen
                            galleryView._pause()
                        } else if (!galleryView.open) {
                            // start playback and go fullscreen
                            galleryView._play()
                        }
                    }
                }
            }

            Loader {
                id: loader

                anchors.centerIn: galleryItem

                sourceComponent: galleryItem.isImage ? imageComponent: videoComponent
            }
        }
    }

    ListView {
        id: pageView

        anchors.fill: parent

        boundsBehavior: Flickable.StopAtBounds
        cacheBuffer: width

        snapMode: ListView.SnapOneItem
        highlightRangeMode: ListView.StrictlyEnforceRange

        orientation: ListView.Horizontal
        currentIndex: count - 1
        pressDelay: 0

        interactive: pageView.count > 1 && !galleryView.positionLocked

        flickDeceleration: Theme.flickDeceleration
        maximumFlickVelocity: Theme.maximumFlickVelocity 

        model: delegateModel

        onCountChanged: {
            if (count == 0) {
                galleryView.open = false
            }
        }

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
                if (page.orientationTransitionRunning && currentIndex != _preOrientationChangeIndex) {
                    // Changing the size of the view can cause the currentIndex to change - fix it.
                    // The recursion doesn't cause any problems. Hurrah.
                    currentIndex = _preOrientationChangeIndex
                    return
                }
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

        Connections {
            target: page
            onOrientationTransitionRunningChanged: {
                if (page.orientationTransitionRunning) {
                    _preOrientationChangeIndex = pageView.currentIndex
                }
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
            Item {
                visible: mediaPlayer.playbackState != MediaPlayer.StoppedState
                width: galleryView.width
                height: galleryView.height
                anchors.centerIn: galleryView._activeItem

                Rectangle {
                    anchors.fill: parent
                    color: 'black'
                    opacity: mediaPlayer.playbackState == MediaPlayer.PlayingState ? 1 : 0
                    Behavior on opacity { FadeAnimation {} }
                }

                GStreamerVideoOutput {
                    id: video

                    anchors.fill: parent
                    source: MediaPlayer {
                        id: mediaPlayer
                        onPlaybackStateChanged: {
                            if (playbackState == MediaPlayer.PlayingState && galleryView.open) {
                                // go fullscreen for playback if triggered via Play icon.
                                galleryView.open = false
                            }
                        }
                    }
                }
            }
        ]

        ViewPlaceholder {
            //: Placeholder text for an empty camera reel view
            //% "Captured photos and videos will appear here when you take some"
            text: qsTrId("camera-la-no-photos")
            enabled: pageView.count == 0 && galleryModel.populated
        }
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
            resolved: pageView.currentItem ? pageView.currentItem.resolved : false

            onDeleteFile: {
                var remorse = remorseComponent.createObject(galleryView)
                var item = pageView.currentItem
                item.ListView.delayRemove = true
                //: Deleting photo or video in 5 seconds
                //% "Deleting"
                remorse.execute(item, qsTrId("camera-la-deleting"), function() {
                    delegateModel.items.remove(item.DelegateModel.itemsIndex, 1)
                    galleryView.model.deleteFile(item.index)
                    remorse.destroy(1)
                    item.ListView.delayRemove = false
                })
            }

            onShowDetails: {
                page.pageStack.push(detailsPage, {modelItem: pageView.currentItem.itemId} )
            }
        }
    ]

    Component {
        id: detailsPage
        DetailsPage {}
    }

    Component {
        id: remorseComponent

        Item {
            id: wrapper

            readonly property bool isActiveItem: parent && parent.active
            onIsActiveItemChanged: {
                if (parent && !parent.active) {
                    remorse.cancel()
                    delegateModel.items.remove(parent.DelegateModel.itemsIndex, 1)
                    galleryView.model.deleteFile(parent.index)
                    wrapper.destroy(1)
                    parent.ListView.delayRemove = false
                }
            }

            x: -pageView.x
            y: -pageView.y
            width: galleryView.foregroundItem.width
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
