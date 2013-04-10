import QtQuick 1.2
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

ClipArea {
    id: clipArea

    signal clicked
    signal northActivated
    signal westActivated
    signal eastActivated
    signal southActivated

    property alias northernIcon: northernImage.source
    property alias westernIcon: westernImage.source
    property alias easternIcon: easternImage.source
    property alias southernIcon: southernImage.source
    property alias centerIcon: centerImage.source

    property bool _drag
    property bool _verticalDrag
    property Item _verticalAction: dragArea.y > 0 ? northernImage: southernImage
    property Item _horizontalAction: dragArea.x > 0 ? westernImage : easternImage
    property Item _currentAction: _verticalDrag ? _verticalAction : _horizontalAction

    property real _verticalPosition: 2 * dragArea.y + (dragArea.y > 0 ? - clipArea.height : clipArea.height)
    property real _horizontalPosition: 2 * dragArea.x + (dragArea.x > 0 ? - clipArea.width : clipArea.width)
    property real _currentPosition: _verticalDrag ? _verticalPosition : _horizontalPosition
    property bool activated: Math.abs(_verticalDrag ? _verticalPosition : _horizontalPosition) < 16

    property real position: _currentPosition
    onPositionChanged: console.log("current position", position, clipArea.width)

    onActivatedChanged: {
        console.log("feedback")
    }

    function _activate() {
        if (_verticalDrag && dragArea.y > 0) {
            clipArea.northActivated()
        } else if (_verticalDrag) {
            clipArea.southActivated()
        } else if (dragArea.x > 0) {
            clipArea.westActivated()
        } else {
            clipArea.eastActivated()
        }
    }

    width: 2 * theme.itemSizeMedium
    height: width

    MouseArea {
        id: horizontalDrag

        width: clipArea.width
        height: clipArea.height
        enabled: !horizontalAnimation.running && !verticalAnimation.running

        drag {
            filterChildren: true
            target: dragArea
            axis: Drag.XAxis
            minimumX: -clipArea.width / 2
            maximumX: clipArea.width / 2

            onActiveChanged: {
                if (drag.active) {
                    clipArea._drag = true
                    clipArea._verticalDrag = false
                }
            }
        }

        onPressed: clipArea._drag = false
        onReleased: {
            horizontalAnimation.start()
            if (clipArea.activated) {
                clipArea._activate()
            }
        }
        onClicked: {
            if (!clipArea._drag) {
                clipArea.clicked()
            }
        }

        MouseArea {
            id: verticalDrag

            width: clipArea.width
            height: clipArea.height

            drag {
                target: dragArea
                axis: Drag.YAxis
                minimumY: -clipArea.height / 2
                maximumY: clipArea.height / 2

                onActiveChanged: {
                    if (drag.active) {
                        clipArea._drag = true
                        clipArea._verticalDrag = true
                    }
                }
            }

            onReleased: {
                verticalAnimation.start()
                if (clipArea.activated) {
                    clipArea._activate()
                }
            }
        }
    }

    Rectangle {
        width: clipArea.width
        height: clipArea.height

        color: theme.highlightBackgroundColor
        opacity: clipArea.activated ? 0.8 : 0.5
    }

    Item {
        id: dragArea

        width: clipArea.width
        height: clipArea.height

        opacity: Math.abs(clipArea._currentPosition / clipArea.width)
        onOpacityChanged: console.log("opacity", opacity, clipArea._currentPosition)

        NumberAnimation on x {
            id: horizontalAnimation
            to: 0
        }

        NumberAnimation on y {
            id: verticalAnimation
            to: 0
        }

        Image {
            id: northernImage
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
        }

        Image {
            id: westernImage
            anchors { left: parent.left; verticalCenter: parent.verticalCenter }

            width: northernImage.width
            height: width
            fillMode: Image.PreserveAspectFit
        }

        Image {
            id: easternImage
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            width: northernImage.width
            height: width
            fillMode: Image.PreserveAspectFit
        }

        Image {
            id: southernImage
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
            width: northernImage.width
            height: width
            fillMode: Image.PreserveAspectFit
        }

        Image {
            id: centerImage
            anchors.centerIn: parent
        }
    }

    Item {
        id: actionArea
        x: !clipArea._verticalDrag ? clipArea._horizontalPosition : 0
        y: clipArea._verticalDrag ? clipArea._verticalPosition : 0
        width: clipArea.width
        height: clipArea.height

        Image {
            id: actionIcon
            anchors.centerIn: parent
            source: clipArea._currentAction.source
        }
    }

}
