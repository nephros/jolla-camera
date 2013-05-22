import QtQuick 1.1
import com.jolla.camera.settings 1.0
import "SettingsIcons.js" as SettingsIcons

MouseArea {
    id: item

    property string mode
    property bool selected: globalSettings.shootingMode == mode
    property url icon: SettingsIcons.shootingMode(Settings, mode)
    property url selectionIcon: icon + "?" + theme.highlightColor

    width: theme.iconSizeLarge
    height: theme.iconSizeLarge

    Image {
        source: icon
        visible: !item.selected
    }

    onClicked: {
        globalSettings.shootingMode = mode
        overlay.open = false
    }
}
