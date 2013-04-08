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
            shootingModePanel.open = false
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

        Item {
            width: page.width
            height: page.height
            y: -shootingModePanel.visibleSize

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

            Rectangle {
                id: focus

                width: theme.itemSizeExtraLarge
                height: theme.itemSizeExtraLarge

                anchors.centerIn: parent

                radius: theme.itemSizeExtraLarge / 2
                border.width: 3
                border.color: theme.highlightColor
                color: "#00000000"
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

            ShootingModeButton {
                id: shootingModeButton

                panel: shootingModePanel

                anchors {
                    left: parent.left
                    bottom: parent.bottom
                    bottomMargin: theme.paddingLarge
                    leftMargin: theme.paddingLarge
                }
            }
        }

        Rectangle {
            width: page.width
            height: page.height

            visible: shootingModePanel.expanded
            opacity: 0.3 - (1 - shootingModeButton.opacity)
            color: theme.highlightBackgroundColor
        }
    }

    ShootingModePanel {
        id: shootingModePanel

        camera: camera
        dock: Dock.Bottom
    }

    SettingsPanel {
        id: settingsPanel

        camera: camera
        dock: Dock.Left

        onOpenChanged: capturePanel.open = !open
    }
}
