import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import com.jolla.camera.settings 1.0

Page {
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

            SectionHeader {
                //% "Photo settings"
                text: qsTrId("camera_settings-ph-photo-settings")
            }

            id: column
            width: parent.width

            SettingsComboBox {
                id: aspectRatio
                //% "Aspect Ratio"
                label: qsTrId("camera_settings-cb-aspect-ratio")
                settings: Settings.global
                property: "aspectRatio"
                menu: ContextMenu {
                    SettingsMenuItem {
                        //% "16:9"
                        text: qsTrId("camera_settings-me-16-9")
                        value: Settings.AspectRatio_16_9
                    }
                    SettingsMenuItem {
                        //% "4:3"
                        text: qsTrId("camera_settings-me-4-3")
                        value: Settings.AspectRatio_4_3
                    }
                }
            }

            SectionHeader {
                //% "Video settings"
                text: qsTrId("camera-ph-video-settings")
            }

            SettingsComboBox {
                id: videoFocus
                width: parent.width
                //: Continuous auto focus
                //% "Continuous AF"
                label: qsTrId("camera_settings-cb-continuous-autofocus")
                settings: Settings.global
                property: "videoFocus"
                menu: ContextMenu {
                    SettingsMenuItem {
                        //% "On"
                        text: qsTrId("camera_settings-me-continuous-autofocus-on")
                        value: Camera.FocusContinuous
                    }
                    SettingsMenuItem {
                        //% "Off"
                        text: qsTrId("camera_settings-me-focus-continuous-autofocus-off")
                        value: Camera.FocusAuto
                    }
                }
            }
        }
    }
}
