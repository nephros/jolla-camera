import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

ExpandingMenu {
    model: Settings.mode.whiteBalanceValues
    delegate: ExpandingMenuItem {
        persistentHighlight: true
        settings: Settings.mode
        property: "whiteBalance"
        value: modelData
        icon: Settings.whiteBalanceIcon(modelData)
        onClicked: parent.open = false
    }
}
