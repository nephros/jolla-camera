import QtQuick 1.2
import Sailfish.Silica 1.0

MouseArea {
    id: button

    property alias diameter: button.width
    height: button.width

    property alias backgroundColor: background.color

    Rectangle {
        id: background

        width: button.width
        height: button.height
        radius: button.width / 2

        color: theme.highlightColor
        opacity: 0.5
    }

    onPressed: {
        var dx = mouse.x - background.radius
        var dy = mouse.y - background.radius

        mouse.accepted = (dx * dx) + (dy * dy) <= (background.radius * background.radius)
    }
}
