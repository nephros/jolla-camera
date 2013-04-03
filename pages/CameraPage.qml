import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import "controls"

Page {
    id: page

    allowedOrientations: Orientation.Portrait | Orientation.Landscape

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
            leftMargin: page.orientation == Orientation.Landscape ? settingsPanel.visibleSize : 0
            topMargin: page.orientation == Orientation.Portrait ? settingsPanel.visibleSize : 0
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
                dock: page.orientation == Orientation.Portrait ? Dock.Right : Dock.Top
                camera: camera

                onOpenSettings: settingsPanel.show()
            }
        }
    }

    SettingsPanel {
        id: settingsPanel

        camera: camera
        dock: page.orientation == Orientation.Portrait ? Dock.Top : Dock.Left

        onOpenChanged: capturePanel.open = !open
    }

    CapturePanel {
        id: capturePanel
        open: true
        camera: camera
        dock: page.orientation == Orientation.Portrait ? Dock.Bottom : Dock.Right
    }

}
