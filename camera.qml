import QtQuick 2.1
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import com.jolla.camera 1.0
import "pages"

ApplicationWindow {
    id: window

    property QtObject _window
    property var captureModel: null
    property bool galleryActive
    property bool galleryVisible
    property int galleryIndex

    onWindowChanged: _window = window ? window : null
    allowedOrientations: defaultAllowedOrientations
    _defaultPageOrientations: Orientation.All
    _defaultLabelFormat: Text.PlainText

    cover: Qt.resolvedUrl("cover/CameraCover.qml")

    initialPage: Component {
        CameraPage {
            id: cameraPage

            pageStack: window.pageStack
            windowVisible: window._window && window._window.visible
            viewfinder: videoOutput
        }
    }

    Rectangle {
        parent: window
        anchors.fill: parent
        z: -1
        color: "black"
    }

    GStreamerVideoOutput {
        id: videoOutput

        z: -1
        width: window.width
        height: window.height

        Behavior on y {
            enabled: !galleryVisible
            NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
        }
    }

    onApplicationActiveChanged:
        if (applicationActive)
            Settings.updateLocation()
}
