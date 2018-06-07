import QtQuick 2.1
import QtQuick.Window 2.1
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import com.jolla.camera 1.0
import QtMultimedia 5.0

ApplicationWindow {
    id: window

    allowedOrientations: defaultAllowedOrientations
    _defaultPageOrientations: Orientation.All
    _defaultLabelFormat: Text.PlainText
    _backgroundVisible: false

    cover: undefined

    Timer {
        running: window.Window.visibility === Window.Hidden
        interval: 20000
        onTriggered: Qt.quit()
    }

    initialPage: Component {
        Page {
            id: cameraPage

            allowedOrientations: captureView.inButtonLayout ? cameraPage.orientation : Orientation.All

            orientationTransitions: Transition {
                to: 'Portrait,Landscape,PortraitInverted,LandscapeInverted'
                from: 'Portrait,Landscape,PortraitInverted,LandscapeInverted'
                SequentialAnimation {
                    PropertyAction {
                        target: cameraPage
                        property: 'orientationTransitionRunning'
                        value: true
                    }
                    FadeAnimation {
                        target: window.pageStack
                        to: 0
                        duration: 150
                    }
                    PropertyAction {
                        target: cameraPage
                        properties: 'width,height,rotation,orientation'
                    }
                    FadeAnimation {
                        target: window.pageStack
                        to: 1
                        duration: 150
                    }
                    PropertyAction {
                        target: cameraPage
                        property: 'orientationTransitionRunning'
                        value: false
                    }
                }
            }

            CaptureView {
                id: captureView

                width: cameraPage.width
                height: cameraPage.height

                active: true
                focus: true

                viewfinder: videoOutput
                orientation: cameraPage.orientation
                pageRotation: cameraPage.rotation

                Binding {
                    target: captureView.viewfinder
                    property: "y"
                    value: cameraPage.orientation == Orientation.LandscapeInverted
                           || cameraPage.orientation == Orientation.PortraitInverted
                           ? -captureView.viewfinderOffset
                           : captureView.viewfinderOffset
                }
            }

            ScreenBlank {
                suspend: captureView.camera.videoRecorder.recorderState == CameraRecorder.RecordingState
            }

            DisabledByMdmView {}
        }
    }

    Item {
        parent: window
        z: -1

        width: window.width
        height: window.height

        Rectangle {
            width: window.width
            height: window.height

            color: "black"
        }

        GStreamerVideoOutput {
            id: videoOutput

            width: window.width
            height: window.height
        }
    }

    onApplicationActiveChanged: {
        if (applicationActive) {
            Settings.updateLocation()
        }
    }
}
