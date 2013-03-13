import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import "controls"

Page {
    id: page

    allowedOrientations: Orientation.Landscape

    Camera {
        id: camera
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            settingsPanel.open = false
            menusPanel.open = true
            capturePanel.open = true
        }
    }

    Item {
        clip: settingsPanel.expanded
        anchors {
            fill: parent
            leftMargin: settingsPanel.visibleSize
        }

        CameraViewport {
            x: -parent.x
            y: -parent.y
            width: page.width
            height: page.height

            camera: camera


            MenusPanel {
                id: menusPanel
                open: true
                settingsPanel: settingsPanel

            }
        }
    }

    SettingsPanel {
        id: settingsPanel

        camera: camera

        onOpenChanged: capturePanel.open = !open
    }

    CapturePanel {
        id: capturePanel
        open: true
        camera: camera
    }
}
