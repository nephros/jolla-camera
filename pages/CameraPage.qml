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

        width: page.width
        height: page.height
        x: settingsPanel.visibleSize

        CameraViewport {
            x: -parent.x / 2
            y: -parent.y / 2
            width: page.width
            height: page.height

            camera: camera
        }

        MenusPanel {
            id: menusPanel
            open: true
            dock: Dock.Top
            camera: camera

            onOpenSettings: settingsPanel.show()
        }

        CapturePanel {
            id: capturePanel
            open: true
            camera: camera
            dock: Dock.Right
        }


        CaptureModeButton {
            camera: camera

            anchors {
                right: parent.right
                bottom: parent.bottom
                bottomMargin: theme.paddingLarge
                rightMargin: theme.paddingLarge
            }
        }
    }

    SettingsPanel {
        id: settingsPanel

        camera: camera
        dock: Dock.Left

        onOpenChanged: capturePanel.open = !open
    }
}
