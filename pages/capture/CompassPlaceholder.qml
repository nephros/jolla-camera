import QtQuick 1.1
import Sailfish.Silica 1.0

MouseArea {
    id: placeholder

    property Item positioner
    property Item opposite
    property bool animating: horizontalAnimation.running || verticalAnimation.running
    property int verticalAlignment: Qt.AlignVCenter
    property int horizontalAlignment

    property bool _swapping: horizontalDrag.pressed

    property real _xOffset: horizontalAlignment == Qt.AlignLeft
                ? dragItem.x
                : positioner.width - dragItem.x - dragItem.width
    property bool willSwap: horizontalDrag.drag.active && _xOffset > (positioner.width - width) / 4

    width: 180
    height: 180

    x: horizontalAlignment == Qt.AlignLeft ? 0 : positioner.width - width
    y: (verticalAlignment == Qt.AlignTop ? 0 : (positioner.height - height))
                / (verticalAlignment == Qt.AlignVCenter ? 2 : 1)

    onWillSwapChanged: {
        var item = horizontalDrag.drag.active ? opposite : placeholder
        item.horizontalAlignment = item.horizontalAlignment == Qt.AlignRight
                    ? Qt.AlignLeft
                    : Qt.AlignRight
    }

    drag {
        filterChildren: true
        target: dragItem
        axis: Drag.YAxis
        minimumY: 0
        maximumY: positioner.height - height
    }
    onReleased: {
        var region = dragItem.y / drag.maximumY
        if (region < 1 / 3) {
            verticalAlignment = Qt.AlignTop
        } else if (region < 2 / 3) {
            verticalAlignment = Qt.AlignVCenter
        } else {
            verticalAlignment = Qt.AlignBottom
        }
    }

    MouseArea {
        id: horizontalDrag

        width: placeholder.width
        height: placeholder.height

        drag {
            target: dragItem
            axis: Drag.XAxis
            minimumX: 0
            maximumX: positioner.width - width
        }
    }

    Rectangle {
        id: dragItem

        parent: placeholder.positioner
        width: placeholder.width
        height: placeholder.height
        radius: 4
        color: theme.highlightBackgroundColor

        Binding {
            target: dragItem
            property: "x"
            value: placeholder.x
            when: !horizontalDrag.drag.active
        }
        Behavior on x {
            enabled: !horizontalDrag.drag.active && placeholder.positioner.enabled
            NumberAnimation {
                id: horizontalAnimation
            }
        }

        Binding {
            target: dragItem
            property: "y"
            value: placeholder.y
            when: !placeholder.drag.active
        }
        Behavior on y {
            enabled: !placeholder.drag.active && placeholder.positioner.enabled
            NumberAnimation {
                id: verticalAnimation
            }
        }

        Rectangle {
            x: placeholder.width / 4
            width: placeholder.width / 2
            radius: 4
            height: placeholder.height
            color: theme.highlightColor
        }
    }
}
