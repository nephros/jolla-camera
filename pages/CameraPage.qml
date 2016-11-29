import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import com.jolla.camera 1.0
import org.nemomobile.dbus 2.0
import QtMultimedia 5.4
import "capture"
import "gallery"

Page {
    id: page

    property bool windowVisible
    property Item pageStack
    property alias viewfinder: captureView.viewfinder
    property bool galleryActive

    Binding {
        target: window
        property: "galleryActive"
        value: page.galleryActive
    }

    Binding {
        target: window
        property: "galleryVisible"
        value: page.galleryActive || switcherView.moving
    }

    Binding {
        target: window
        property: "galleryIndex"
        value: galleryLoader.item ? galleryLoader.item.currentIndex : 0
    }

    Binding {
        target: window
        property: "captureModel"
        value: galleryLoader.item ? galleryLoader.item.captureModel : null
    }

    allowedOrientations: captureView.inButtonLayout ? page.orientation : Orientation.All

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

    Timer {
        running: Qt.application.state != Qt.ApplicationActive && switcherView.currentIndex != 1
        interval: 15*60*1000
        onTriggered: {
            switcherView.currentIndex = 1
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
                    && !captureView.recording
        currentIndex: 1
        focus: true

        flickDeceleration: Theme.flickDeceleration
        maximumFlickVelocity: Theme.maximumFlickVelocity 

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

                readonly property real _viewfinderPosition: orientation == Orientation.Portrait || orientation == Orientation.Landscape
                                                            ? parent.x + x
                                                            : -parent.x - x
                width: page.width
                height: page.height

                active: true

                orientation: page.orientation
                windowVisible: page.windowVisible
                pageRotation: page.rotation

                visible: switcherView.moving || captureView.active

                onLoaded: {
                    if (galleryLoader.source == "") {
                        galleryLoader.setSource("gallery/GalleryView.qml", { page: page })
                    }
                }

                CameraRollHint { z: 2 }
                CameraModeHint { z: 2 }

                Binding {
                    target: captureView.viewfinder
                    property: "x"
                    value: captureView.isPortrait
                           ? captureView._viewfinderPosition
                           : 0
                }

                Binding {
                    target: captureView.viewfinder
                    property: "y"
                    value: !captureView.isPortrait
                            ? captureView._viewfinderPosition + (page.orientation == Orientation.Landscape ? captureView.viewfinderOffset : -captureView.viewfinderOffset)
                            : captureView.viewfinderOffset
                }
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
                    galleryLoader.setSource("gallery/GalleryView.qml", { page: page })
                } else if (galleryLoader.item) {
                    galleryLoader.item.positionViewAtBeginning()
                }
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

        signal showFrontViewfinder()
        onShowFrontViewfinder: {
            Settings.cameraDevice = "secondary"
            switcherView.positionViewAtEnd()
            window.activate()
        }
    }
}
