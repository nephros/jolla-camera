import QtQuick 2.0
import Sailfish.Silica 1.0


Item {
    id: indicator

    property real zoom
    property real maximumZoom

    property color color: Theme.highlightColor

    implicitWidth: Screen.width - (2 * Theme.horizontalPageMargin)
    implicitHeight: Theme.itemSizeSmall

    opacity: opacityAnimation.running ? 1 : 0
    Behavior on opacity { FadeAnimation { id: opacityBehavior } }
    visible: opacityAnimation.running || opacityBehavior.running

    function show() {
        if (!opacityBehavior.running) {
            opacityAnimation.restart()
        }
    }

    Label {
        anchors {
            horizontalCenter: dot.horizontalCenter
            top: indicator.top
        }

        color: indicator.color
        font.pixelSize: Theme.fontSizeTiny
        //: Title for current zoom position
        //% "Zoom"
        text: qsTrId("jolla-camera-la-zoom")
    }

    Rectangle {
        id: line

        anchors {
            verticalCenter: parent.verticalCenter
            left: minimumLabel.horizontalCenter
            right: maximumLabel.horizontalCenter
        }
        height: Theme.paddingSmall / 2
        radius: height / 2

        color: indicator.color
    }

    Rectangle {
        id: dot
        anchors {
            verticalCenter: line.verticalCenter
            horizontalCenter: line.left
            horizontalCenterOffset: indicator.maximumZoom > 1
                        ? line.width * (indicator.zoom - 1) / (indicator.maximumZoom - 1)
                        : line.width / 2
        }

        width: Theme.paddingMedium
        height: Theme.paddingMedium
        radius: height / 2

        color: indicator.color
    }

    Label {
        id: minimumLabel

        anchors {
            left: parent.left
            bottom: parent.bottom
        }

        color: indicator.color
        font.pixelSize: Theme.fontSizeTiny
        //: Abbreviated text for minimum extent of the zoom indicator
        //% "min"
        text: qsTrId("jolla-camera-la-zoom_min")
    }

    Label {
        id: maximumLabel

        anchors {
            right: parent.right
            bottom: parent.bottom
        }

        color: indicator.color
        font.pixelSize: Theme.fontSizeTiny
        //: Abbreviated text for maximum extent of the zoom indicator
        //% "max"
        text: qsTrId("jolla-camera-la-zoom_max")
    }

    PauseAnimation {
        id: opacityAnimation
        duration: 2000
    }
}
