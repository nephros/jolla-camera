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

            SettingsCompass {
                id: settingsCompass

                camera: camera

                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    margins: theme.paddingLarge
                }

                onClicked: settingsPanel.show()
            }

            ShootingModeButton {
                id: shootingModeButton

                panel: shootingModePanel

                anchors {
                    left: parent.left
                    top: settingsCompass.bottom
                    margins: theme.paddingLarge
                }
            }

            Rectangle {
                id: focus

                width: theme.itemSizeExtraLarge
                height: width

                anchors.centerIn: parent

                radius: width / 2
                border.width: 3
                border.color: theme.highlightColor
                color: "#00000000"
            }

            LastPhotoIcon {
                camera: camera

                anchors {
                    bottom: captureCompass.top
                    right: parent.right
                    margins: theme.paddingLarge
                }
            }

            CaptureCompass {
                id: captureCompass

                camera: camera

                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: theme.paddingLarge
                }
            }

            CaptureModeButton {
                camera: camera

                anchors {
                    top: captureCompass.bottom
                    right: parent.right
                    margins: theme.paddingLarge
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
    }
}
