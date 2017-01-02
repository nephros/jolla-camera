import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

ExpandingMenu {
    model: Settings.global.whiteBalanceValues
    delegate: ExpandingMenuItem {
        persistentHighlight: true
        settings: Settings.global
        property: "whiteBalance"
        value: modelData
        icon: Settings.whiteBalanceIcon(modelData)
    }
}
