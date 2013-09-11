import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import "SettingsIcons.js" as SettingsIcons

MouseArea {
    id: item

    property string mode
    property bool selected: Settings.global.shootingMode == mode
    property url icon: SettingsIcons.shootingMode(mode)
    property url selectionIcon: icon + "?" + Theme.highlightColor

    width: Theme.iconSizeMedium
    height: Theme.iconSizeMedium

    Image {
        source: icon
        visible: !item.selected

        anchors.centerIn: parent
    }

    onClicked: {
        Settings.global.shootingMode = mode
        overlay._close()
    }
}
