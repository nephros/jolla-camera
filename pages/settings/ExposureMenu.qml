import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

ExpandingMenu {
    //% "Exposure compensation"
    title: qsTrId("jolla-camera-la-exposure_compensation")
    model: Settings.mode.exposureCompensationValues
    delegate: ExpandingMenuItem {
        settings: Settings.mode
        property: "exposureCompensation"
        value: modelData
        icon: Settings.exposureIcon(modelData)
    }
}
