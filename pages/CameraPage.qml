import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0
import QtDocGallery 5.0
import QtMultimedia 5.0
import "capture"
import "settings"
import "gallery"

Page {
    id: page

    property bool windowActive
    property Item pageStack
    property alias viewfinder: captureView.viewfinder

    allowedOrientations: Orientation.Portrait | Orientation.Landscape

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
        interactive: !galleryView.positionLocked && captureModel.count > 0
        currentIndex: 1

        model: VisualItemModel {
            GalleryView {
                id: galleryView

                width: page.width
                height: page.height

                page: page
                model: captureModel
                active: false
                windowActive: page.windowActive
                isPortrait: page.orientation == Orientation.Portrait
                            || page.orientation == Orientation.PortraitInverted

                visible: switcherView.moving || galleryView.active
            }

            CaptureView {
                id: captureView

                width: page.width
                height: page.height

                active: true

                orientation: page.orientation
                windowActive: page.windowActive

                visible: switcherView.moving || captureView.active

                camera.imageCapture.onImageSaved: {
                    captureModel.appendCapture(path, "image/jpeg", camera.extensions.orientation, 0)
                }

                onRecordingStopped: {
                    captureModel.appendCapture(url, mimeType, camera.extensions.orientation, camera.videoRecorder.duration / 1000)
                }
            }
        }

        onCurrentItemChanged: {
            if (!moving) {
                galleryView.active = galleryView.ListView.isCurrentItem
                captureView.active = captureView.ListView.isCurrentItem
            }
        }

        onMovingChanged: {
            if (!moving) {
                galleryView.active = galleryView.ListView.isCurrentItem
                captureView.active = captureView.ListView.isCurrentItem
            } else if (captureView.active) {
                galleryView.positionViewAtBeginning()
            }
        }
    }

    CaptureModel {
        id: captureModel

        source: DocumentGalleryModel {
            rootType: DocumentGallery.File
            properties: [ "url", "title", "mimeType", "orientation", "duration" ]
            sortProperties: ["fileName"]
            autoUpdate: true
            filter: GalleryFilterUnion {
                GalleryEqualsFilter { property: "path"; value: Settings.photoDirectory }
                GalleryEqualsFilter { property: "path"; value: Settings.videoDirectory }
            }
        }

        onCountChanged: {
            if (count == 0) {
                switcherView.currentIndex = 1
            }
        }
    }

    ScreenBlank {
        suspend: galleryView.playing || captureView.camera.captureMode == Camera.CaptureVideo
    }
}
