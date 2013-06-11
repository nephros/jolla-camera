import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import org.nemomobile.dbus 1.0
import com.jolla.camera 1.0

SilicaFlickable {
    id: panel

    property Camera camera

    width: parent.width
    height: parent.height

    contentHeight: column.height

    PullDownMenu {
        id: menu

        MenuItem {
            //% "Open Gallery"
            text: qsTrId("camera-me-open-gallery")
            onClicked:  galleryService.call("showPhotos", undefined)
        }
    }

    VerticalScrollDecorator {}

    Column {
        SectionHeader {
            //% "Photo settings"
            text: qsTrId("camera-ph-photo-settings")
        }

        id: column
        width: parent.width

        SettingsComboBox {
            id: iso
            width: parent.width
            //% "ISO"
            label: qsTrId("camera-cb-iso")
            settings: Settings.mode
            property: "iso"
            visible: Settings.mode.isoConfigurable
            menu: ContextMenu {
                SettingsMenuItem {
                    //% "Automatic"
                    text: qsTrId("camera-me-iso-automatic")
                    value: 0
                }
                Repeater {
                    model: [ 100, 200, 400, 800, 1600 ]
                    SettingsMenuItem {
                        text: modelData
                        value: modelData
                    }
                }
            }
        }

        SettingsComboBox {
            id: whiteBalance
            width: parent.width
            //% "White Balance"
            label: qsTrId("camera-cb-white-balance")
            settings: Settings.mode
            property: "whiteBalance"
            visible: Settings.mode.whiteBalanceConfigurable
            menu: ContextMenu {
                SettingsMenuItem {
                    //% "Auto"
                    text: qsTrId("camera-me-white-balance-auto")
                    value: CameraImageProcessing.WhiteBalanceAuto
                }
                SettingsMenuItem {
                    //% "Sunlight"
                    text: qsTrId("camera-me-white-balance-sunlight")
                    value: CameraImageProcessing.WhiteBalanceSunlight
                }
                SettingsMenuItem {
                    //% "Cloudy"
                    text: qsTrId("camera-me-white-balance-cloudy")
                    value: CameraImageProcessing.WhiteBalanceCloudy
                }
                SettingsMenuItem {
                    //% "Shade"
                    text: qsTrId("camera-me-white-balance-shade")
                    value: CameraImageProcessing.WhiteBalanceShade
                }
                SettingsMenuItem {
                    //% "Tungsten"
                    text: qsTrId("camera-me-white-balance-tungsten")
                    value: CameraImageProcessing.WhiteBalanceTungsten
                }
                SettingsMenuItem {
                    //% "Fluorescent"
                    text: qsTrId("camera-me-white-balance-fluorescent")
                    value: CameraImageProcessing.WhiteBalanceFluorescent
                }
                SettingsMenuItem {
                    //% "Incandescent"
                    text: qsTrId("camera-me-white-balance-incandescent")
                    value: CameraImageProcessing.WhiteBalanceIncandescent
                }
                SettingsMenuItem {
                    //% "Flash"
                    text: qsTrId("camera-me-white-balance-flash")
                    value: CameraImageProcessing.WhiteBalanceFlash
                }
                SettingsMenuItem {
                    //% "Sunset"
                    text: qsTrId("camera-me-white-balance-sunset")
                    value: CameraImageProcessing.WhiteBalanceSunset
                }
            }
        }

        SettingsComboBox {
            id: aspectRatio
            //% "Aspect Ratio"
            label: qsTrId("camera-cb-aspect-ratio")
            settings: Settings.global
            property: "aspectRatio"
            menu: ContextMenu {
                SettingsMenuItem {
                    //% "16:9"
                    text: qsTrId("camera-me-16-9")
                    value: CameraExtensions.AspectRatio_16_9
                }
                SettingsMenuItem {
                    //% "4:3"
                    text: qsTrId("camera-me-4-3")
                    value: CameraExtensions.AspectRatio_4_3
                }
            }
        }

        SettingsComboBox {
            id: focusDistance
            width: parent.width
            //% "Focus length"
            label: qsTrId("camera-cb-focus-distance")
            settings: Settings.mode
            property: "focusDistance"
            visible: Settings.mode.focusDistanceConfigurable
            menu: ContextMenu {
                SettingsMenuItem {
                    //% "Automatic"
                    text: qsTrId("camera-me-focus-automatic")
                    value: Camera.FocusAuto
                }
                SettingsMenuItem {
                    //% "Hyperfocal"
                    text: qsTrId("camera-me-focus-hyperfocal")
                    value: Camera.FocusHyperfocal
                }
                SettingsMenuItem {
                    //% "Infinite"
                    text: qsTrId("camera-me-focus-infinite")
                    value: Camera.FocusInfinity
                }
                SettingsMenuItem {
                    //% "Macro"
                    text: qsTrId("camera-me-focus-macro")
                    value: Camera.FocusMacro
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
            label: qsTrId("camera-cb-continuous-autofocus")
            settings: Settings.mode
            property: "videoFocus"
            menu: ContextMenu {
                SettingsMenuItem {
                    //% "On"
                    text: qsTrId("camera-me-continuous-autofocus-on")
                    value: Camera.FocusAuto
                }
                SettingsMenuItem {
                    //% "Off"
                    text: qsTrId("camera-me-focus-continuous-autofocus-off")
                    value: Camera.FocusContinuous
                }
            }
        }
    }

    DBusInterface {
        id: galleryService

        destination: "com.jolla.gallery"
        path: "/com/jolla/gallery/ui"
        iface: "com.jolla.gallery.ui"
    }
}
