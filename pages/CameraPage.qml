import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import "controls"

Page {
    allowedOrientations: Orientation.Landscape

    Camera {
        id: cameraObject
    }

    CameraViewport {
        anchors.fill: parent

        camera: cameraObject
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            settingsPanel.open = true
            capturePanel.open = true
        }
    }

    SettingsPanel {
        id: settingsPanel
        open: true
        camera: cameraObject
    }

    CapturePanel {
        id: capturePanel
        open: true
        camera: cameraObject
    }
}
