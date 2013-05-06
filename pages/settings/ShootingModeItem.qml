import QtQuick 1.1
import com.jolla.camera.settings 1.0

MouseArea {
    id: item

    property string mode
    property bool selected: globalSettings.shootingMode == mode
    property url icon
    property url selectionIcon: icon + "?" + theme.highlightColor

    width: theme.itemSizeExtraLarge
    height: theme.itemSizeExtraLarge

    Image {
        anchors.centerIn: parent

        source: item.selected
                ? icon + "?" + theme.highlightColor
                : icon
    }

    onClicked: {
        globalSettings.shootingMode = mode
        overlay.open = false
    }
}
