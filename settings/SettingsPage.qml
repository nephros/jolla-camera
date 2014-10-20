import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import org.nemomobile.configuration 1.0

Page {
    onStatusChanged: {
        if (status == PageStatus.Activating) {
            Settings.updateLocation()
        }
    }

    ConfigurationGroup {
        id: globalSettings

        path: "/apps/jolla-camera"

        ConfigurationGroup {
            id: primaryImageSettings

            path: "primary/image"

            property string imageResolution
            property string viewfinderResolution
            property string imageResolution_16_9
            property string viewfinderResolution_16_9
            property string resolutionText_16_9
            property string imageResolution_4_3
            property string viewfinderResolution_4_3
            property string resolutionText_4_3
        }

        ConfigurationGroup {
            id: secondaryImageSettings

            path: "secondary/image"

            property string imageResolution
            property string viewfinderResolution
            property string imageResolution_16_9
            property string viewfinderResolution_16_9
            property string resolutionText_16_9
            property string imageResolution_4_3
            property string viewfinderResolution_4_3
            property string resolutionText_4_3
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
                        text: qsTrId(primaryImageSettings.resolutionText_16_9)
                        imageResolution: primaryImageSettings.imageResolution_16_9
                        viewfinderResolution: primaryImageSettings.viewfinderResolution_16_9

                    }
                    ResolutionComboItem {
                        text: qsTrId(primaryImageSettings.resolutionText_4_3)
                        imageResolution: primaryImageSettings.imageResolution_4_3
                        viewfinderResolution: primaryImageSettings.viewfinderResolution_4_3
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
                        text: qsTrId(secondaryImageSettings.resolutionText_16_9)
                        imageResolution: secondaryImageSettings.imageResolution_16_9
                        viewfinderResolution: secondaryImageSettings.viewfinderResolution_16_9
                    }
                    ResolutionComboItem {
                        text: qsTrId(secondaryImageSettings.resolutionText_4_3)
                        imageResolution: secondaryImageSettings.imageResolution_4_3
                        viewfinderResolution: secondaryImageSettings.viewfinderResolution_4_3
                    }
                }
            }
        }
    }
}
