import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

Item {
    id: compass

    signal clicked

    property alias topAction: topAction
    property alias leftAction: leftAction
    property alias rightAction: rightAction
    property alias bottomAction: bottomAction
    property alias icon: centerImage.source
    property alias buttonEnabled: centerImage.visible

    property bool keepSelection

    property bool animating: horizontalAnimation.running || verticalAnimation.running
    property bool expanded: _menu != null

    property bool pressed: (horizontalDrag.pressed || verticalDrag.pressed) && !_drag && centerImage.visible

    property bool _drag
    property bool _verticalDrag
    property CompassAction _verticalAction: dragArea.y > 0 ? topAction: bottomAction
    property CompassAction _horizontalAction: dragArea.x > 0 ? leftAction : rightAction
    property CompassAction _currentAction: _verticalDrag ? _verticalAction : _horizontalAction

    property real _verticalPosition: 2 * dragArea.y + (dragArea.y > 0 ? - compass.height : compass.height)
    property real _horizontalPosition: 2 * dragArea.x + (dragArea.x > 0 ? - compass.width : compass.width)
    property real _currentPosition: _verticalDrag ? _verticalPosition : _horizontalPosition
    property bool activated: (horizontalDrag.pressed || verticalDrag.pressed || keepSelection)
                && Math.abs(_verticalDrag ? _verticalPosition : _horizontalPosition) < 16

    property Item _menu
    property real _menuOpacity: 1.0 - buttons.opacity
    property bool _closingMenu

    property QtObject buttonBuzz

    Component.onCompleted: {
        buttonBuzz = Qt.createQmlObject(
                    "import QtQuick 1.1; import QtMobility.feedback 1.1; ThemeEffect { effect: ThemeEffect.BasicButton }",
                    compass,
                    'ThemeEffect')
    }

    onActivatedChanged: {
        if (activated && buttonBuzz) {
            buttonBuzz.play()
        }
    }

    onKeepSelectionChanged: {
        if (!keepSelection && !_menu) {
            horizontalAnimation.running = true
            verticalAnimation.running = true
        }
    }

    function openMenu(menu) {
        if (compass._menu) {
            console.log("the current menu must be closed before a new one can be opened.")
            return
        }

        compass._menu = menu.createObject(clipArea.contentItem, { compass: compass })
        if (!_menu) {
            console.log("failed to create menu")
            console.log(menu.errorString)
            return
        }

        opacityAnimation.to = 0.0
        heightAnimation.to = _menu.height
        compass._closingMenu = false

        menuAnimation.running = true
    }

    function closeMenu() {
        if (_menu && !compass._closingMenu) {
            opacityAnimation.to = 1.0
            heightAnimation.to = compass.height
            compass._closingMenu = true

            if (!menuAnimation.running) {
                menuAnimation.running = true
            } else {
                horizontalAnimation.running = true
                verticalAnimation.running = true
                menuAnimation.restart()
            }
        }
    }

    width: theme.itemSizeExtraLarge + theme.paddingMedium
    height: width

    CompassAction { id: topAction }
    CompassAction { id: leftAction }
    CompassAction { id: rightAction }
    CompassAction { id: bottomAction }

    MouseArea {
        id: horizontalDrag

        width: compass.width
        height: compass.height
        enabled: !horizontalAnimation.running
                    && !verticalAnimation.running
                    && !compass._menu
                    && !compass.keepSelection

        drag {
            filterChildren: true
            target: dragArea
            axis: Drag.XAxis
            minimumX: rightAction.enabled ? -compass.width / 2 : 0
            maximumX: leftAction.enabled ? compass.width / 2 : 0

            onActiveChanged: {
                if (drag.active) {
                    compass._drag = true
                    compass._verticalDrag = false
                }
            }
        }

        onPressed: compass._drag = false
        onReleased: {
            if (compass.activated) {
                compass._currentAction.activated()
            }
            if (compass._drag && !compass._menu && (!compass.activated || !compass.keepSelection)) {
                horizontalAnimation.start()
            }
        }
        onClicked: {
            if (!compass._drag && centerImage.visible) {
                compass.clicked()
            }
        }

        MouseArea {
            id: verticalDrag

            width: compass.width
            height: compass.height

            enabled: horizontalDrag.enabled

            drag {
                target: dragArea
                axis: Drag.YAxis
                minimumY: bottomAction.enabled ? -compass.height / 2 : 0
                maximumY: topAction.enabled ? compass.height / 2 : 0

                onActiveChanged: {
                    if (drag.active) {
                        compass._drag = true
                        compass._verticalDrag = true
                    }
                }
            }

            onReleased: {
                if (compass.activated) {
                    compass._currentAction.activated()
                }
                if (compass._drag && !compass._menu && (!compass.activated || !compass.keepSelection)) {
                    verticalAnimation.start()
                }
            }
        }
    }

    Rectangle {
        anchors.fill: clipArea

        radius: compass.width / 2
        color: theme.highlightBackgroundColor
        opacity: compass.activated || compass.pressed ? 1.0 : 0.3
        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }
    }

    ClipArea {
        id: clipArea

        property alias contentItem: clipArea

        width: compass.width
        height: compass.height

        anchors.centerIn: parent

        Item {
            id: buttons

            width: compass.width
            height: compass.height
            anchors.centerIn: parent

            Item {
                id: dragArea

                width: compass.width
                height: compass.height


                NumberAnimation on x {
                    id: horizontalAnimation
                    to: 0
                }

                NumberAnimation on y {
                    id: verticalAnimation
                    to: 0
                }

                opacity: Math.abs(compass._currentPosition / compass.width)

                Image {
                    anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; margins: theme.paddingSmall }
                    width: 24; height: 24
                    fillMode: Image.PreserveAspectFit
                    source: topAction.smallIcon
                    visible: topAction.enabled
                }

                Image {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; margins: theme.paddingSmall }
                    width: 24; height: 24
                    fillMode: Image.PreserveAspectFit
                    source: leftAction.smallIcon
                    visible: leftAction.enabled
                }

                Image {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter; margins: theme.paddingSmall }
                    width: 24; height: 24
                    fillMode: Image.PreserveAspectFit
                    source: rightAction.smallIcon
                    visible: rightAction.enabled
                }

                Image {
                    anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; margins: theme.paddingSmall }
                    width: 24; height: 24
                    fillMode: Image.PreserveAspectFit
                    source: bottomAction.smallIcon
                    visible: bottomAction.enabled
                }

                Image {
                    id: centerImage
                    anchors.centerIn: parent
                }
            }
            Item {
                id: actionArea
                x: !compass._verticalDrag ? compass._horizontalPosition : 0
                y: compass._verticalDrag ? compass._verticalPosition : 0
                width: compass.width
                height: compass.height

                Image {
                    id: actionIcon
                    anchors.centerIn: parent
                    source: compass._currentAction.largeIcon
                }
            }
        }
    }

    ParallelAnimation {
        id: menuAnimation

        NumberAnimation {
            id: opacityAnimation

            target: buttons
            property: "opacity"
        }
        NumberAnimation {
            id: heightAnimation

            target: clipArea
            property: "height"
        }

        onRunningChanged: {
            if (running) {
                // else
            } else if (compass._closingMenu) {
                compass._menu.destroy()
                compass._menu = null
            } else {
                dragArea.x = 0
                dragArea.y = 0
            }
        }
    }
}
