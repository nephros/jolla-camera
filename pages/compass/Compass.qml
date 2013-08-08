import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

Item {
    id: compass

    signal clicked
    signal pressAndHold

    property alias topAction: topAction
    property alias leftAction: leftAction
    property alias rightAction: rightAction
    property alias bottomAction: bottomAction
    property bool interactive: true

    property alias contentItem: dragArea
    default property alias _data: dragArea.data

    property real topMargin
    property real bottomMargin

    property bool centerMenu
    property bool keepSelection
    property int verticalAlignment

    property bool animating: horizontalAnimation.running || verticalAnimation.running
    property bool expanded: _menu != null

    property bool pressed: (horizontalDrag.pressed || verticalDrag.pressed) && !_drag

    property bool _drag
    property bool _held
    property bool _verticalDrag
    property CompassAction _verticalAction: dragArea.y > 0 ? topAction: bottomAction
    property CompassAction _horizontalAction: dragArea.x > 0 ? leftAction : rightAction
    property CompassAction _currentAction: _verticalDrag ? _verticalAction : _horizontalAction

    property real _verticalPosition: 2 * dragArea.y + (dragArea.y > 0 ? -compass.width : compass.width)
    property real _horizontalPosition: 2 * dragArea.x + (dragArea.x > 0 ? -compass.width : compass.width)
    property real _currentPosition: _verticalDrag ? _verticalPosition : _horizontalPosition
    property bool activated: (horizontalDrag.pressed || verticalDrag.pressed || keepSelection)
                && Math.abs(_verticalDrag ? _verticalPosition : _horizontalPosition) < 16

    property Item _menu
    property real _menuOpacity: 1.0 - buttons.opacity
    property bool _closingMenu

    property QtObject buttonBuzz

    Component.onCompleted: {
        buttonBuzz = Qt.createQmlObject(
                    "import QtQuick 2.0; import QtFeedback 5.0; ThemeEffect { effect: ThemeEffect.Press }",
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

        compass._closingMenu = false
        opacityAnimation.to = 0
        clipArea.state = "menuOpen"
    }

    function closeMenu() {
        if (_menu && !compass._closingMenu) {
            compass._closingMenu = true
            opacityAnimation.to = 1
            if (menuAnimation.running) {
                horizontalAnimation.running = true
                verticalAnimation.running = true
            } else {
                dragArea.x = 0
                dragArea.y = 0
                actionArea.visible = false
            }

            clipArea.state = "menuClosed"
        }
    }

    width: 180
    height: 180

    CompassAction { id: topAction }
    CompassAction { id: leftAction }
    CompassAction { id: rightAction }
    CompassAction { id: bottomAction }

    MouseArea {
        id: horizontalDrag

        width: compass.width
        height: compass.width
        anchors.centerIn: clipArea
        enabled: !horizontalAnimation.running
                    && !verticalAnimation.running
                    && !compass._menu
                    && !compass.keepSelection

        drag {
            filterChildren: true
            target: !compass._held ? dragArea : null
            axis: Drag.XAxis
            minimumX: compass.interactive && rightAction.enabled ? -compass.width / 2 : 0
            maximumX: compass.interactive && leftAction.enabled ? compass.width / 2 : 0

            onActiveChanged: {
                if (drag.active) {
                    compass._drag = true
                    compass._verticalDrag = false
                    actionArea.visible = true
                }
            }
        }

        onPressed: {
            compass._drag = false
            compass._held = false
        }
        onReleased: {
            if (compass.activated) {
                compass._currentAction.activated()
            }
            if (compass._drag && !compass._menu && (!compass.activated || !compass.keepSelection)) {
                horizontalAnimation.start()
            }
        }

        onClicked: {
            if (!compass._drag) {
                compass.clicked()
            }
        }
        onPressAndHold: {
            if (!compass._drag) {
                compass._held = true
                compass.pressAndHold()
            }
        }

        MouseArea {
            id: verticalDrag

            width: compass.width
            height: compass.width

            enabled: horizontalDrag.enabled

            drag {
                target: !compass._held ? dragArea : null
                axis: Drag.YAxis
                minimumY: compass.interactive && bottomAction.enabled ? -compass.width / 2 : 0
                maximumY: compass.interactive && topAction.enabled ? compass.width / 2 : 0

                onActiveChanged: {
                    if (drag.active) {
                        compass._drag = true
                        compass._verticalDrag = true
                        actionArea.visible = true
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
        anchors {
            fill: clipArea
            margins: -4 // radius
        }

        radius: 4
        color: compass.activated || compass.pressed ? Theme.highlightBackgroundColor : Theme.highlightDimmerColor
        opacity: compass.activated || compass.pressed ? 1.0 : 0.6
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on opacity { FadeAnimation {} }
    }

    Item {
        id: buttonAnchor
        anchors {
            fill: compass
            topMargin: compass.topMargin + compass.width / 2
            bottomMargin: compass.bottomMargin + compass.width / 2
        }
    }

    Item {
        id: positioner
        height: compass.width
        anchors {
            left: compass.left
            right: compass.right
            verticalCenter: compass.verticalAlignment != Qt.AlignVCenter
                        ? (compass.verticalAlignment == Qt.AlignTop ? buttonAnchor.top : buttonAnchor.bottom)
                        : buttonAnchor.verticalCenter
            leftMargin: (1 - leftImage.opacity) * compass.width / 4
            rightMargin: (1 - rightImage.opacity) * compass.width / 4
        }
    }

    Item {
        id: clipArea

        property alias contentItem: clipArea

        height: compass.width
        clip: true
        state: "menuClosed"
        states: [
            State {
                name: "menuClosed"
                AnchorChanges {
                    target: clipArea
                    anchors {
                        left: positioner.left; top: positioner.top
                        right: positioner.right; bottom: positioner.bottom
                    }
                }
            }, State {
                name: "menuOpen"
                AnchorChanges {
                    target: clipArea
                    anchors {
                        left: compass.left; top: compass.top
                        right: compass.right; bottom: compass.bottom
                    }
                }
            }
        ]

        transitions: Transition {
            SequentialAnimation {
                id: menuAnimation
                NumberAnimation { id: opacityAnimation; target: buttons; property: "opacity" }
                ScriptAction { script:
                    if (compass._closingMenu) {
                        compass._menu.destroy()
                        compass._menu = null
                    }
                }
            }
            AnchorAnimation { duration: opacityAnimation.duration }
        }

        Item {
            id: buttons

            width: compass.width
            height: compass.width
            y: positioner.y - clipArea.y
            anchors.horizontalCenter: clipArea.horizontalCenter

            Item {
                id: dragArea

                width: compass.width
                height: compass.width


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
                    anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; margins: Theme.paddingLarge }
                    width: 24; height: 24
                    fillMode: Image.PreserveAspectFit
                    source: topAction.smallIcon
                    opacity: compass.interactive && topAction.enabled ? 1 : 0
                    Behavior on opacity { FadeAnimation {} }
                }

                Image {
                    id: leftImage
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; margins: Theme.paddingLarge }
                    width: 24; height: 24
                    fillMode: Image.PreserveAspectFit
                    source: leftAction.smallIcon
                    opacity: compass.interactive && leftAction.enabled ? 1 : 0
                    Behavior on opacity { FadeAnimation {} }
                }

                Image {
                    id: rightImage
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter; margins: Theme.paddingLarge }
                    width: 24; height: 24
                    fillMode: Image.PreserveAspectFit
                    source: rightAction.smallIcon
                    opacity: compass.interactive && rightAction.enabled ? 1 : 0
                    Behavior on opacity { FadeAnimation {} }
                }

                Image {
                    anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; margins: Theme.paddingLarge }
                    width: 24; height: 24
                    fillMode: Image.PreserveAspectFit
                    source: bottomAction.smallIcon
                    opacity: compass.interactive && bottomAction.enabled ? 1 : 0
                    Behavior on opacity { FadeAnimation {} }
                }
            }
            Item {
                id: actionArea
                x: !compass._verticalDrag ? compass._horizontalPosition : 0
                y: compass._verticalDrag ? compass._verticalPosition : 0
                width: compass.width
                height: compass.width

                Image {
                    id: actionIcon
                    anchors.centerIn: parent
                    source: compass._currentAction.largeIcon
                }
            }
        }
    }
}
