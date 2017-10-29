import QtQuick 2.1
import QtQml.Models 2.1
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0
import Sailfish.Media 1.0
import QtDocGallery 5.0
import com.jolla.camera 1.0
import org.nemomobile.policy 1.0
import ".."

ListView {
    id: root

    readonly property bool positionLocked: (active && currentItem && currentItem.scaled) || (!overlay.active && playing)

    readonly property bool active: page.galleryActive
    property alias captureModel: captureModelItem

    property CameraPage page

    readonly property QtObject player: playerLoader.item ? playerLoader.item.player : null
    readonly property bool playing: player && player.playing
    property int _preOrientationChangeIndex
    property Item _remorsePopup

    function _positionViewAtBeginning() {
        currentIndex = count - 1
        positionViewAtEnd()
    }

    model: delegateModel
    boundsBehavior: Flickable.StopAtBounds
    cacheBuffer: width

    snapMode: ListView.SnapOneItem
    highlightRangeMode: ListView.StrictlyEnforceRange
    // Normally transition is handled through a different path when flicking,
    // avoid slow transition if triggered by ListView for some reason
    highlightMoveDuration: 300

    orientation: ListView.Horizontal
    currentIndex: count - 1
    pressDelay: 0

    clip: true
    interactive: count > 1 && !positionLocked
    flickDeceleration: Theme.flickDeceleration
    maximumFlickVelocity: Theme.maximumFlickVelocity

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
        if (_remorsePopup && _remorsePopup.active) {
            _remorsePopup.trigger()
        }
    }
    onActiveChanged: if (!active) overlay.active = true

    property Item previousItem
    onMovingChanged: {
        if (moving) {
            previousItem = currentItem
        } else if (player && previousItem != currentItem) {
            player.reset()
        }
    }


    CaptureModel {
        id: captureModelItem

        source: DocumentGalleryModel {
            id: galleryModel

            property bool populated

            rootType: DocumentGallery.File
            properties: [ "url", "mimeType", "orientation", "duration", "width", "height" ]
            sortProperties: ["lastModified"]
            autoUpdate: true
            filter: GalleryFilterUnion {
                GalleryEqualsFilter { property: "path"; value: Settings.photoDirectory }
                GalleryEqualsFilter { property: "path"; value: Settings.videoDirectory }
            }
            onStatusChanged: {
                if (status === DocumentGalleryModel.Finished) {
                    populated = true
                    _positionViewAtBeginning()
                }
            }
        }
    }

    DelegateModel {
        id: delegateModel

        model: captureModel

        delegate: Loader {
            readonly property var itemId: model.itemId
            readonly property int index: model.index
            readonly property string mimeType: model.mimeType
            readonly property url source: model.url
            readonly property bool resolved: model.resolved
            readonly property int duration: model.duration

            readonly property bool isImage: mimeType.indexOf("image/") == 0
            readonly property bool scaled: item && item.scaled

            readonly property bool isCurrentItem: PathView.isCurrentItem

            width: root.width
            height: root.height
            sourceComponent: isImage ? imageComponent: videoComponent
            asynchronous: !isCurrentItem

            Component {
                id: imageComponent

                ImageViewer {

                    onClicked: overlay.active = !overlay.active
                    source: parent.source

                    active: isCurrentItem
                    orientation: model.orientation
                    enableZoom: !moving && !overlay.active
                    interactive: scaled && !overlay.active

                }
            }

            Component {
                id: videoComponent

                VideoPoster {
                    onClicked: overlay.active = !overlay.active
                    onTogglePlay: {
                        playerLoader.active = true
                        player.togglePlay()
                    }

                    contentWidth: root.width
                    contentHeight: root.height

                    source: parent.source
                    mimeType: model.mimeType
                    playing: player && player.playing
                    loaded: player && player.loaded
                    overlayMode: overlay.active
                }
            }
        }
    }

    Connections {
        target: page
        onOrientationTransitionRunningChanged: {
            if (page.orientationTransitionRunning) {
                _preOrientationChangeIndex = root.currentIndex
            }
        }
    }

    ViewPlaceholder {
        //: Placeholder text for an empty camera reel view
        //% "Captured photos and videos will appear here when you take some"
        text: qsTrId("camera-la-no-photos")
        enabled: count == 0 && galleryModel.populated
    }

    contentItem.children: [
        FadeBlocker {
            z: -1
            anchors.fill: parent
        },
        Loader {
            id: playerLoader

            active: false
            width: root.width
            height: root.height
            sourceComponent: GStreamerVideoOutput {
                property alias player: mediaPlayer
                visible: player.playbackState != MediaPlayer.StoppedState
                source: GalleryMediaPlayer {
                    id: mediaPlayer
                    active: currentItem && !currentItem.isImage && Qt.application.active
                    source: active ? currentItem.source : ""
                    onPlayingChanged: {
                        if (playing && overlay.active) {
                            // go fullscreen for playback if triggered via Play icon.
                            overlay.active = false
                        }
                    }
                    onLoadedChanged: if (loaded) playerLoader.anchors.centerIn = currentItem
                }
            }
        }
    ]

    GalleryOverlay {
        id: overlay

        onRemove: {
            if (!_remorsePopup) {
                _remorsePopup = remorsePopupComponent.createObject(root)
            }
            if (!_remorsePopup.active && currentItem) {
                var item = currentItem
                //: Delete an image
                //% "Deleting"
                _remorsePopup.execute( qsTrId("gallery-la-deleting"), function() {
                    delegateModel.items.remove(item.DelegateModel.itemsIndex, 1)
                    delegateModel.model.deleteFile(item.index)
                    item.ListView.delayRemove = false
                })
            }
        }
        onCreatePlayer: playerLoader.active = true

        anchors.fill: parent
        player: root.player
        source: currentItem ? currentItem.source : ""
        itemId: currentItem ? currentItem.itemId : ""
        isImage: currentItem ? currentItem.isImage : true
        duration: currentItem ? currentItem.duration : 1
        editingAllowed: false

        IconButton {
            y: Theme.paddingLarge
            anchors {
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
            }
            icon.source: "image://theme/icon-m-dismiss"
            onClicked: switcherView.returnToCaptureMode()
        }
    }
    Component {
        id: remorsePopupComponent
        RemorsePopup {}
    }
}
