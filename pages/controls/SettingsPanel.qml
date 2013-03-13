import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

DockedPanel {
    id: panel

    property Camera camera

    width: parent.height
    height: parent.height
    dock: Dock.Left

    contentHeight: column.height

    Column {
        width: parent.width
        id: column
        ComboBox {
            id: flashMode
            width: parent.width
            //: Settings
            //% "Flash"
            label: qsTrId("camera-cb-flash-mode")
            currentIndex: 2
            onCurrentItemChanged: panel.camera.flash.mode = currentItem.value
            visible: panel.camera.captureMode == Camera.Still
            //: Flash Settings
            menu: ContextMenu {
                SettingsMenuItem {
                    //% "Off"
                    text: qsTrId("camera-me-flash-off")
                    value: Flash.Off
                }
                SettingsMenuItem {
                    //% "On"
                    text: qsTrId("camera-me-flash-on")
                    value: Flash.On
                }
                SettingsMenuItem {
                    //% "Auto"
                    text: qsTrId("camera-me-flash-auto")
                    value: Flash.Auto
                }
            }
        }

        ComboBox {
            id: focusDistance
            width: parent.width
            //: Settings
            //% "Focus"
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
                    //% "Normal"
                    text: qsTrId("camera-me-focus-normal")
                    value: Focus.Normal
                }
                SettingsMenuItem {
                    //% "Hyperfocal"
                    text: qsTrId("camera-me-flash-hyperfocal")
                    value: Focus.Hyperfocal
                }
                SettingsMenuItem {
                    //% "Infinite"
                    text: qsTrId("camera-me-flash-auto")
                    value: Focus.Infinite
                }
                SettingsMenuItem {
                    //% "Macro"
                    text: qsTrId("camera-me-flash-auto")
                    value: Focus.Macro
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
            id: exposure
            width: parent.width
            //: Settings
            //% "Exposure"
            label: qsTrId("camera-cb-exposure")
            currentIndex: 4
            onCurrentItemChanged: camera.exposure.compensation = currentItem.value
            menu: ContextMenu {
                SettingsMenuItem { text: value ; value: -2 }
                SettingsMenuItem { text: value ; value: -1.5 }
                SettingsMenuItem { text: value ; value: -1 }
                SettingsMenuItem { text: value ; value: -0.5 }
                SettingsMenuItem { text: value ; value: 0 }
                SettingsMenuItem { text: value ; value: 0.5 }
                SettingsMenuItem { text: value ; value: 1 }
                SettingsMenuItem { text: value ; value: 1.5 }
                SettingsMenuItem { text: value ; value: 2 }
            }
        }
    }
}
