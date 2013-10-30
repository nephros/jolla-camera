import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import "pages"
import "cover"

ApplicationWindow {
    id: window
    cover: Component{
        CameraCover {
        }
    }

    initialPage: Component {
        CameraPage {
            id: cameraPage

            pageStack: window.pageStack
            windowActive: window.applicationActive
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
}
