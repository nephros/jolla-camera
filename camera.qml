import QtQuick 2.1
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import "pages"
import "cover"

ApplicationWindow {
    id: window

    property QtObject _window
    onWindowChanged: _window = window ? window : null
    allowedOrientations: defaultAllowedOrientations
    _defaultPageOrientations: Orientation.All

    cover: Component{
        CameraCover {
        }
    }

    initialPage: Component {
        CameraPage {
            id: cameraPage

            pageStack: window.pageStack
            windowVisible: window._window && window._window.visible
            viewfinder: videoOutput
        }
    }

    Rectangle {
        anchors.fill: videoOutput
        z: -1
        color: "black"
    }

    GStreamerVideoOutput {
        id: videoOutput

        z: -1
        width: window.width
        height: window.height
    }

    onApplicationActiveChanged:
        if (applicationActive)
            Settings.updateLocation()
}
