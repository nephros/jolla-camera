import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import org.nemomobile.configuration 1.0

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

            IconTextSwitch {
                automaticCheck: false
                icon.source: "image://theme/icon-m-gps"
                //: Save GPS coordinates in photos.
                //% "Save location"
                text: qsTrId("camera_settings-la-save_location")
                description: Settings.locationEnabled
                            //% "Save current GPS coordinates in captured photos."
                            ? qsTrId("camera_settings-la-save_location_description")
                            //% "Positioning is turned off.  Enable it in Settings | System | Location"
                            : qsTrId("camera_settings-la-enable_location")

                enabled: Settings.locationEnabled
                checked: Settings.global.saveLocationInfo && Settings.locationEnabled
                onClicked: Settings.global.saveLocationInfo = !Settings.global.saveLocationInfo
            }

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
                        viewfinderResolution: "960x540"

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
                        viewfinderResolution: "960x540"
                    }
                    ResolutionComboItem {
                        //: "2 mega pixel image resolution with 4:3 aspect ratio"
                        //% "4:3 (2Mpix)"
                        text: qsTrId("camera_settings-me-4-3-2m")
                        imageResolution: "1600x1200"
                        viewfinderResolution: "640x480"
                    }
                }
            }
        }
    }
}
