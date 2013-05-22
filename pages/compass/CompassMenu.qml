import QtQuick 1.1
import Sailfish.Silica 1.0

SilicaFlickable {
    id: menu

    property Item compass

    property QtObject settings
    property string property
    property alias contentItem: contentItem
    property alias model: repeater.model
    property alias delegate: repeater.delegate

    default property alias _data: contentItem.data
    property real _paddedHeight: contentItem.height + 96

    width: compass.width
    height: Math.min(compass.height, _paddedHeight)
    y: compass.centerMenu
            ? -parent.y + (compass.height - height) / 2
            : -parent.y + compass.height - height

    anchors.horizontalCenter: parent.horizontalCenter
    opacity: compass._menuOpacity

    contentHeight: _paddedHeight

    Component.onCompleted: contentY = (contentHeight - height) / 2

    Column {
        id: contentItem
        y: 48

        property alias _compass: menu.compass
        property alias _property: menu.property
        property alias _settings: menu.settings

        width: menu.width

        Repeater {
            id: repeater
        }
    }
}
