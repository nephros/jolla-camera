import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import com.jolla.camera 1.0
import com.jolla.camera 1.0
import org.nemomobile.dbus 1.0
import QtDocGallery 5.0
import QtMultimedia 5.0
import "capture"
import "settings"
import "gallery"

Page {
    id: page

    property bool windowVisible
    property Item pageStack
    property alias viewfinder: captureView.viewfinder
    property bool galleryActive

    allowedOrientations: Orientation.Portrait
                | Orientation.PortraitInverted
                | Orientation.Landscape
                | Orientation.LandscapeInverted

    orientationTransitions: Transition {
        to: 'Portrait,Landscape,PortraitInverted,LandscapeInverted'
        from: 'Portrait,Landscape,PortraitInverted,LandscapeInverted'
        SequentialAnimation {
            PropertyAction {
                target: page
                property: 'orientationTransitionRunning'
                value: true
            }
            FadeAnimation {
                target: page.pageStack
                to: 0
                duration: 150
            }
            PropertyAction {
                target: page
                properties: 'width,height,rotation,orientation'
            }
            FadeAnimation {
                target: page.pageStack
                to: 1
                duration: 150
            }
            PropertyAction {
                target: page
                property: 'orientationTransitionRunning'
                value: false
            }
        }
    }

    ListView {
        id: switcherView

        width: page.width
        height: page.height

        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        boundsBehavior: Flickable.StopAtBounds
        highlightRangeMode: ListView.StrictlyEnforceRange
        interactive: (!galleryLoader.item || !galleryLoader.item.positionLocked)
                    && captureModel.count > 0
                    && !captureView.recording
        currentIndex: 1
        focus: true

        model: VisualItemModel {
            Item {
                id: galleryItem

                width: page.width
                height: page.height

                Loader {
                    id: galleryLoader

                    anchors.fill: parent

                    asynchronous: true
                    visible: switcherView.moving || page.galleryActive
                }

                BusyIndicator {
                    id: galleryIndicator
                    visible: galleryLoader.status == Loader.Loading
                    anchors.centerIn: parent
                    size: BusyIndicatorSize.Large
                    running: true
                }
            }

            CaptureView {
                id: captureView

                width: page.width
                height: page.height

                active: true

                orientation: page.orientation
                windowVisible: page.windowVisible

                visible: switcherView.moving || captureView.active

                camera.imageCapture.onImageSaved: {
                    captureModel.appendCapture(
                                path,
                                "image/jpeg",
                                camera.extensions.orientation,
                                0,
                                camera.imageCapture.resolution)
                }

                onRecordingStopped: {
                    captureModel.appendCapture(
                                url,
                                mimeType,
                                camera.extensions.orientation,
                                camera.videoRecorder.duration / 1000,
                                camera.videoRecorder.resolution)
                }

                onLoaded: {
                    if (galleryLoader.source == "") {
                        galleryLoader.setSource("gallery/GalleryView.qml", { page: page, model: captureModel })
                    }
                }

                onInButtonLayoutChanged: {
                    page.allowedOrientations = inButtonLayout
                            ? page.orientation
                            : Orientation.Portrait
                                | Orientation.PortraitInverted
                                | Orientation.Landscape
                                | Orientation.LandscapeInverted
                }
                CameraRollHint {}
            }
        }

        onCurrentItemChanged: {
            if (!moving) {
                page.galleryActive = galleryItem.ListView.isCurrentItem
                captureView.active = captureView.ListView.isCurrentItem
            }
        }

        onMovingChanged: {
            if (!moving) {
                page.galleryActive = galleryItem.ListView.isCurrentItem
                captureView.active = captureView.ListView.isCurrentItem
            } else if (captureView.active) {
                if (galleryLoader.source == "") {
                    galleryLoader.setSource("gallery/GalleryView.qml", { page: page, model: captureModel })
                } else if (galleryLoader.item) {
                    galleryLoader.item.positionViewAtBeginning()
                }
            }
        }

        onDraggingChanged: {
            if (!dragging && captureModel.count == 0) {
                switcherView.currentIndex = 1
            }
        }
    }

    CaptureModel {
        id: captureModel

        source: DocumentGalleryModel {
            rootType: DocumentGallery.File
            properties: [ "url", "title", "mimeType", "orientation", "duration", "width", "height" ]
            sortProperties: ["fileName"]
            autoUpdate: true
            filter: GalleryFilterUnion {
                GalleryEqualsFilter { property: "path"; value: Settings.photoDirectory }
                GalleryEqualsFilter { property: "path"; value: Settings.videoDirectory }
            }
        }

        onCountChanged: {
            if (count == 0 && !switcherView.dragging) {
                switcherView.currentIndex = 1
            }
        }
    }

    ScreenBlank {
        suspend: (galleryLoader.item && galleryLoader.item.playing)
                    || captureView.camera.videoRecorder.recorderState == CameraRecorder.RecordingState
    }

    DBusAdaptor {
        iface: "com.jolla.camera.ui"
        service: "com.jolla.camera"
        path: "/"

        signal showViewfinder(variant args)
        onShowViewfinder: {
            switcherView.positionViewAtEnd()
            window.activate()
        }
    }
}
