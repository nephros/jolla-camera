import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import com.jolla.camera.settings 1.0

Page {
    GConfSettings {
        id: globalSettings

        path: "/apps/jolla-camera"

        GConfSettings {
            id: primaryImageSettings

            path: "primary/image"

            property size imageResolution
            property size viewfinderResolution
        }

        GConfSettings {
            id: secondaryImageSettings

            path: "secondary/image"

            property size imageResolution
            property size viewfinderResolution
        }
    }

    SilicaFlickable {
        id: panel

        width: parent.width
        height: parent.height

        contentHeight: column.height

        VerticalScrollDecorator {}

        Column {
            PageHeader {
                //% "Camera"
                title: qsTrId("camera_settings-ph-camera")
            }

            id: column
            width: parent.width

            SectionHeader {
                //% "Back camera"
                text: qsTrId("camera-ph-back-camera")
            }

            ResolutionComboBox {
                settings: primaryImageSettings

                //% "Photo resolution"
                label: qsTrId("camera_settings-cb-photo-resolution")
                menu: ContextMenu {
                    ResolutionComboItem {
                        //: "6 mega pixel image resolution with 16:9 aspect ratio"
                        //% "16:9 (6Mpix)"
                        text: qsTrId("camera_settings-me-16-9-6m")
                        imageResolution: "3264x1840"
                        viewfinderResolution: "768x432"

                    }
                    ResolutionComboItem {
                        //: "8 mega pixel image resolution with 4:3 aspect ratio"
                        //% "4:3 (8Mpix)"
                        text: qsTrId("camera_settings-me-4-3-8m")
                        imageResolution: "3264x2448"
                        viewfinderResolution: "640x480"
                    }
                }
            }

            SectionHeader {
                //% "Front camera"
                text: qsTrId("camera-ph-front-camera")
            }

            ResolutionComboBox {
                settings: secondaryImageSettings

                label: qsTrId("camera_settings-cb-photo-resolution")
                menu: ContextMenu {
                    ResolutionComboItem {
                        //: "1 mega pixel image resolution with 16:9 aspect ratio"
                        //% "16:9 (1Mpix)"
                        text: qsTrId("camera_settings-me-16-9-1m")
                        imageResolution: "1280x720"
                        viewfinderResolution: "768x432"
                    }
                    ResolutionComboItem {
                        //: "0.3 mega pixel image resolution with 4:3 aspect ratio"
                        //% "4:3 (0.3Mpix)"
                        text: qsTrId("camera_settings-me-4-3-0.3m")
                        imageResolution: "640x480"
                        viewfinderResolution: "640x480"
                    }
                }
            }
        }
    }
}
