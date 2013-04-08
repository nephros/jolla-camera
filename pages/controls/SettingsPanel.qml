import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

DockedPanel {
    id: panel

    property Camera camera

    width: parent.width / 2
    height: parent.height

    contentHeight: column.height

    PullDownMenu {
        id: menu
    }

    Column {
        PageHeader {
            //: Settings
            //% "Photo settings"
            title: qsTrId("camera-ph-photo-settings")
        }

        id: column
        width: parent.width

        ComboBox {
            id: iso
            width: parent.width
            //: Settings
            //% "ISO"
            label: qsTrId("camera-cb-iso")
            currentIndex: 0
            onCurrentItemChanged: {
                if (currentItem) {
                    panel.camera.exposure.iso = currentItem.value
                }
            }
            //: Focus Settings
            menu: ContextMenu {
                SettingsMenuItem {
                    //% "Automatic"
                    text: qsTrId("camera-me-iso-automatic")
                }
                Repeater {
                    model: panel.exposure.supportedIso
                    SettingsMenuItem {
                        text: modelData
                        value: modelData
                    }
                }
            }
        }

        ComboBox {
            id: whiteBalance
            width: parent.width
            //: Settings
            //% "White Balance"
            label: qsTrId("camera-cb-white-balance")
            currentIndex: 0
            onCurrentItemChanged: panel.camera.whiteBalance = currentItem.value
            //: White Balance Settings
            menu: ContextMenu {
                SettingsMenuItem {
                    //% "Auto"
                    text: qsTrId("camera-me-white-balance-auto")
                    value: WhiteBalance.Auto
                }
                SettingsMenuItem {
                    //% "Sunlight"
                    text: qsTrId("camera-me-white-balance-sunlight")
                    value: WhiteBalance.Sunlight
                }
                SettingsMenuItem {
                    //% "Cloudy"
                    text: qsTrId("camera-me-white-balance-cloudy")
                    value: WhiteBalance.Cloudy
                }
                SettingsMenuItem {
                    //% "Shade"
                    text: qsTrId("camera-me-white-balance-shade")
                    value: WhiteBalance.Shade
                }
                SettingsMenuItem {
                    //% "Tungsten"
                    text: qsTrId("camera-me-white-balance-tungsten")
                    value: WhiteBalance.Tungsten
                }
                SettingsMenuItem {
                    //% "Fluorescent"
                    text: qsTrId("camera-me-white-balance-fluorescent")
                    value: WhiteBalance.Fluorescent
                }
                SettingsMenuItem {
                    //% "Incandescent"
                    text: qsTrId("camera-me-white-balance-incandescent")
                    value: WhiteBalance.Incandescent
                }
                SettingsMenuItem {
                    //% "Flash"
                    text: qsTrId("camera-me-white-balance-flash")
                    value: WhiteBalance.Flash
                }
                SettingsMenuItem {
                    //% "Sunset"
                    text: qsTrId("camera-me-white-balance-sunset")
                    value: WhiteBalance.Sunset
                }
            }
        }

        ComboBox {
            id: aspectRatio
            //: Settings
            //% "Aspect Ratio"
            label: qsTrId("camera-cb-aspect-ratio")
            currentIndex: 0
            // Hook up to something.

            //: Focus Settings
            menu: ContextMenu {
                SettingsMenuItem {
                    //% "16:9"
                    text: qsTrId("camera-me-16-9")
                }
                SettingsMenuItem {
                    //% "4:3"
                    text: qsTrId("camera-me-4-3")
                }
            }
        }

        ComboBox {
            id: focusDistance
            width: parent.width
            //: Settings
            //% "Focus length"
            label: qsTrId("camera-cb-focus-distance")
            currentIndex: 0
            onCurrentItemChanged: {
                if (currentItem) {
                    panel.camera.focus.distance = currentItem.value
                }
            }
            //: Focus Settings
            menu: ContextMenu {
                SettingsMenuItem {
                    //% "Automatic"
                    text: qsTrId("camera-me-focus-automatic")
                    value: Focus.Normal
                }
                SettingsMenuItem {
                    //% "Hyperfocal"
                    text: qsTrId("camera-me-focus-hyperfocal")
                    value: Focus.Hyperfocal
                }
                SettingsMenuItem {
                    //% "Infinite"
                    text: qsTrId("camera-me-focus-infinite")
                    value: Focus.Infinite
                }
                SettingsMenuItem {
                    //% "Macro"
                    text: qsTrId("camera-me-focus-macro")
                    value: Focus.Macro
                }
            }
        }

        PageHeader {
            //: Settings
            //% "Video settings"
            title: qsTrId("camera-ph-video-settings")
        }
    }
}
