import QtQuick 1.1
import Sailfish.Silica 1.0

SilicaFlickable {
    id: menu

    property Item compass

    property string property
    property alias contentItem: contentItem

    default property alias _data: contentItem.data
    property real _minimumHeight: compass.width
    property real _maximumHeight: screen.width - theme.itemSizeLarge
    property real _paddedHeight: contentItem.height + (2 * theme.paddingLarge)

    width: compass.width
    height: Math.min(menu._paddedHeight, menu._maximumHeight)
    anchors.centerIn: parent
    opacity: compass._menuOpacity

    contentHeight: _paddedHeight

    Component.onCompleted: contentY = (_paddedHeight - height) / 2

    Column {
        id: contentItem

        property alias _compass: menu.compass
        property alias _property: menu.property

        y: theme.paddingLarge
        width: menu.width
    }
}
