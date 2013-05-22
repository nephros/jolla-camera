import QtQuick 1.1
import Sailfish.Silica 1.0

// ### Modified and QtQuick 2.0 ported version of SplitItem from jollacomponents-internal.
// Consider rolling changes back if it doesn't diverge too far from original design.

Item {
    id: root

    property bool split

    property int dock: Dock.Bottom

    property real _progress: split ? 1.0 : 0.0
    property bool contracted: split || menuProgressAnimation.running

    property alias backgroundItem: backgroundItem
    property alias background: backgroundItem.children

    property alias foregroundItem: foregroundItem
    property alias foreground: foregroundItem.children

    default property alias data: foregroundItem.data

    Behavior on _progress {
        id: menuProgressBehavior
        NumberAnimation {
            id: menuProgressAnimation
            duration: 500
            easing.type: Easing.InOutQuad
        }
    }

    onDockChanged: menuProgressAnimation.complete()

    function show(immediate) {
        split = true
        if (immediate)
            menuProgressAnimation.complete()
    }

    function hide(immediate) {
        split = false
        if (immediate)
            menuProgressAnimation.complete()
    }

    Item {
        id: backgroundItem

        visible: root.contracted
        opacity: _progress
        anchors {
            fill: parent
            leftMargin: root.dock == Dock.Left ? root.width / 2 : 0
            topMargin: root.dock == Dock.Top ? root.height / 2 : 0
            rightMargin: root.dock == Dock.Right ? root.width / 2 : 0
            bottomMargin: root.dock == Dock.Bottom ? root.height / 2 : 0
        }
    }

    Item {
        id: foregroundItem
        clip: root.contracted ? true : false

        anchors {
            fill: parent
            leftMargin: root.dock == Dock.Right ? _progress * root.width / 2 : 0
            topMargin: root.dock == Dock.Bottom ? _progress * root.height / 2 : 0
            rightMargin: root.dock == Dock.Left ? _progress * root.width / 2 : 0
            bottomMargin: root.dock == Dock.Top ? _progress * root.height / 2 : 0
        }
    }
}
