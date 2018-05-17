import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import org.nemomobile.configuration 1.0
import org.nemomobile.systemsettings 1.0
import com.jolla.settings.system 1.0
import Sailfish.Policy 1.0

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
            property string imageResolution_4_3
            property string viewfinderResolution_4_3
        }

        ConfigurationGroup {
            id: secondaryImageSettings

            path: "secondary/image"

            property string imageResolution
            property string viewfinderResolution
            property string imageResolution_16_9
            property string viewfinderResolution_16_9
            property string imageResolution_4_3
            property string viewfinderResolution_4_3
        }

        ConfigurationGroup {
            id: primaryVideoSettings

            path: "primary/video"

            property string videoResolution
            property string viewfinderResolution
            property string videoResolution_1080p
            property string viewfinderResolution_1080p
            property string videoResolution_720p
            property string viewfinderResolution_720p
            property string videoResolution_360p
            property string viewfinderResolution_360p
        }

        ConfigurationGroup {
            id: secondaryVideoSettings

            path: "secondary/video"

            property string videoResolution
            property string viewfinderResolution
            property string videoResolution_1080p
            property string viewfinderResolution_1080p
            property string videoResolution_720p
            property string viewfinderResolution_720p
            property string videoResolution_360p
            property string viewfinderResolution_360p
        }
    }

    function resolutionText(ratioHorizontal, ratioVertical, resolution) {
        var dimensions = resolution.split("x")
        var megaPixels = dimensions.length == 2 ? (Math.round((dimensions[0] * dimensions[1]) / 1000000))
                                                : "?"
        //: template for resolution text, %1 and %2 are aspect ratio, %3 is megapixel value. e.g. 16:9 (2Mpix)"
        //% "%1:%2 (%3Mpix)"
        return qsTrId("camera_settings-me-resolution_template").arg(ratioHorizontal).arg(ratioVertical).arg(megaPixels)
    }

    function videoResolutionText(resolution) {
        var dimensions = resolution.split("x")
        return dimensions[1] + "p"
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

            DisabledByMdmBanner {
                active: !AccessPolicy.cameraEnabled
            }

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

                enabled: Settings.locationEnabled && AccessPolicy.cameraEnabled
                checked: Settings.global.saveLocationInfo && Settings.locationEnabled
                onClicked: Settings.global.saveLocationInfo = !Settings.global.saveLocationInfo
            }

            ComboBox {
                id: storageCombo
                property int storageStatus: Settings.storagePathStatus
                property string storagePath: Settings.storagePath

                function updateCurrentIndex() {
                    for (var i = 0; i < menu.children.length; ++i) {
                        var item = menu.children[i]
                        if (item.hasOwnProperty("__silica_menuitem") && item.visible && item.mountPath == Settings.storagePath) {
                            currentIndex = i
                            return
                        }
                    }
                    currentIndex = -1
                }

                onStorageStatusChanged: updateCurrentIndex()
                onStoragePathChanged: updateCurrentIndex()
                Component.onCompleted: updateCurrentIndex()

                //% "Storage"
                label: qsTrId("camera_settings-cb-storage")
                enabled: AccessPolicy.cameraEnabled
                menu: ContextMenu {
                    MenuItem {
                        property string mountPath: ""
                        //% "Device memory"
                        text: qsTrId("camera_settings-la-device_memory")
                        onClicked: Settings.storagePath = ""
                    }
                    MenuItem {
                        // This is a placeholder for a card that was previously selected, but is no longer inserted
                        property string mountPath: Settings.storagePath
                        text: qsTrId("camera_settings-la-memory_card_not_inserted")
                        visible: partitions.count == 0 && Settings.storagePath !== ""
                        onVisibleChanged: storageCombo.updateCurrentIndex()
                        opacity: 0.4
                    }
                    Repeater {
                        model: partitions
                        onCountChanged: storageCombo.updateCurrentIndex()
                        delegate: MenuItem {
                            property string mountPath: model.mountPath
                            onMountPathChanged: storageCombo.updateCurrentIndex()
                            text: model.status == PartitionModel.Mounted
                                    //: the parameter is the capacity of the memory card, e.g. "4.2 GB"
                                    //% "Memory card %1"
                                  ? qsTrId("camera_settings-la-memory_card").arg(Format.formatFileSize(model.bytesAvailable))
                                  : model.devicePath !== ""
                                        //% "Memory card not mounted"
                                      ? qsTrId("camera_settings-la-unmounted_memory_card")
                                        //% "Memory card not inserted"
                                      : qsTrId("camera_settings-la-memory_card_not_inserted")
                            opacity: model.devicePath !== "" && model.status == PartitionModel.Mounted ? 1.0 : 0.4
                            onClicked: Settings.storagePath = model.mountPath
                        }
                    }
                }
            }

            Label {
                //% "The selected storage is not available. Device memory will be used instead."
                text: qsTrId("camera_settings-la-unwritable")
                visible: Settings.storagePathStatus == Settings.Unavailable
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
            }

            SectionHeader {
                //% "Back camera"
                text: qsTrId("camera-ph-back-camera")
                opacity: AccessPolicy.cameraEnabled ? 1.0 : 0.4
            }

            ResolutionComboBox {
                settings: primaryImageSettings

                //% "Photo resolution"
                label: qsTrId("camera_settings-cb-photo-resolution")
                enabled: AccessPolicy.cameraEnabled
                menu: ContextMenu {
                    ResolutionComboItem {
                        text: resolutionText(16, 9, imageResolution)
                        imageResolution: primaryImageSettings.imageResolution_16_9
                        viewfinderResolution: primaryImageSettings.viewfinderResolution_16_9

                    }
                    ResolutionComboItem {
                        text: resolutionText(4, 3, imageResolution)
                        imageResolution: primaryImageSettings.imageResolution_4_3
                        viewfinderResolution: primaryImageSettings.viewfinderResolution_4_3
                    }
                }
            }

            VideoResolutionComboBox {
                settings: primaryVideoSettings

                //% "Video resolution"
                label: qsTrId("camera_settings-cb-video-resolution")
                enabled: AccessPolicy.cameraEnabled
                visible: primaryVideoSettings.videoResolution_360p != ""
                menu: ContextMenu {
                    ResolutionComboItem {
                        text: videoResolutionText(videoResolution)
                        videoResolution: primaryVideoSettings.videoResolution_1080p
                        viewfinderResolution: primaryVideoSettings.viewfinderResolution_1080p
                    }
                    ResolutionComboItem {
                        text: videoResolutionText(videoResolution)
                        videoResolution: primaryVideoSettings.videoResolution_720p
                        viewfinderResolution: primaryVideoSettings.viewfinderResolution_720p
                    }
                    ResolutionComboItem {
                        text: videoResolutionText(videoResolution)
                        videoResolution: primaryVideoSettings.videoResolution_360p
                        viewfinderResolution: primaryVideoSettings.viewfinderResolution_360p
                    }
                }
            }

            SectionHeader {
                //% "Front camera"
                text: qsTrId("camera-ph-front-camera")
                opacity: AccessPolicy.cameraEnabled ? 1.0 : 0.4
            }

            ResolutionComboBox {
                settings: secondaryImageSettings

                label: qsTrId("camera_settings-cb-photo-resolution")
                enabled: AccessPolicy.cameraEnabled
                menu: ContextMenu {
                    ResolutionComboItem {
                        text: resolutionText(16, 9, imageResolution)
                        imageResolution: secondaryImageSettings.imageResolution_16_9
                        viewfinderResolution: secondaryImageSettings.viewfinderResolution_16_9
                    }
                    ResolutionComboItem {
                        text: resolutionText(4, 3, imageResolution)
                        imageResolution: secondaryImageSettings.imageResolution_4_3
                        viewfinderResolution: secondaryImageSettings.viewfinderResolution_4_3
                    }
                }
            }

            VideoResolutionComboBox {
                settings: secondaryVideoSettings

                //% "Video resolution"
                label: qsTrId("camera_settings-cb-video-resolution")
                enabled: AccessPolicy.cameraEnabled
                visible: secondaryVideoSettings.videoResolution_360p != ""
                menu: ContextMenu {
                    ResolutionComboItem {
                        text: videoResolutionText(videoResolution)
                        videoResolution: secondaryVideoSettings.videoResolution_1080p
                        viewfinderResolution: secondaryVideoSettings.viewfinderResolution_1080p
                    }
                    ResolutionComboItem {
                        text: videoResolutionText(videoResolution)
                        videoResolution: secondaryVideoSettings.videoResolution_720p
                        viewfinderResolution: secondaryVideoSettings.viewfinderResolution_720p
                    }
                    ResolutionComboItem {
                        text: videoResolutionText(videoResolution)
                        videoResolution: secondaryVideoSettings.videoResolution_360p
                        viewfinderResolution: secondaryVideoSettings.viewfinderResolution_360p
                    }
                }
            }
        }
    }

    PartitionModel {
        id: partitions
        storageTypes: PartitionModel.External | PartitionModel.ExcludeParents
    }
}
