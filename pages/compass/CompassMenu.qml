import QtQuick 1.1
import Sailfish.Silica 1.0

SilicaFlickable {
    id: menu

    property Item compass
    property alias contentItem: contentItem
    property alias title: titleLabel.text

    default property alias _data: contentItem.data
    property real _minimumHeight: compass.width
    property real _maximumHeight: screen.width - theme.itemSizeLarge
    property real _paddedHeight: contentItem.height + menu._minimumHeight - theme.paddingMedium

    width: compass.width
    height: Math.min(menu._paddedHeight, menu._maximumHeight)
    anchors.centerIn: parent
    opacity: compass._menuOpacity

    contentHeight: _paddedHeight

    Label {
        id: titleLabel

        width: menu.width
        anchors { bottom: contentItem.top }
        font.pixelSize: theme.fontSizeExtraSmall

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Column {
        id: contentItem

        property Item _compass: menu.compass

        y: theme.paddingSmall + menu._minimumHeight / 2
        width: menu.width
    }
}
