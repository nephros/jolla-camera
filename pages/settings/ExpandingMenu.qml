import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    id: menu

    property alias title: titleText.text
    property alias model: repeater.model
    property alias delegate: repeater.delegate
    property alias currentItem: column.currentItem
    property alias alignment: titleText.horizontalAlignment

    property bool open
    readonly property alias expanded: column.itemsVisible

    width: Theme.itemSizeSmall
    height: Theme.itemSizeSmall
    anchors.centerIn: parent

    onClicked: menu.open = true

    Column {
        id: column

        property Item currentItem
        readonly property alias itemOpacity: titleText.opacity
        readonly property bool itemsVisible: menu.open || fadeAnimation.running
        readonly property alias pressed: menu.pressed
        property alias open: menu.open
        property real itemHeight: menu.open ? menu.height : 0
        Behavior on itemHeight {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        anchors.bottom: menu.bottom
        width: menu.width

        Repeater {
            id: repeater
        }

        enabled: menu.open
    }

    Label {
        id: titleText

        anchors {
            horizontalCenter: menu.horizontalCenter
            horizontalCenterOffset: (menu.alignment == Text.AlignRight ? -menu.width : menu.width) + Theme.paddingMedium
            verticalCenter: column.verticalCenter
        }

        width: menu.width

        color: Theme.highlightBackgroundColor
        font {
            pixelSize: Theme.fontSizeExtraSmall
            bold: true
        }
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter

        opacity: menu.open ? 1.0 : 0.0

        Behavior on opacity {
            FadeAnimation { id: fadeAnimation }
        }
    }
}
