import QtQuick 1.1
import Sailfish.Silica 1.0

Item {
    id: positioner

    property real topMargin
    property real bottomMargin

    property bool animating: settingsPlaceholder.animating || capturePlaceholder.animating

    Rectangle {
        color: theme.highlightDimmerColor
        opacity: 0.6
        anchors.fill: parent
    }

    MouseArea {
        width: positioner.width
        height: positioner.height
        onClicked: {
            globalSettings.reverseButtons = settingsPlaceholder.horizontalAlignment == Qt.AlignRight
            globalSettings.settingsVerticalAlignment = settingsPlaceholder.verticalAlignment
            globalSettings.captureVerticalAlignment = capturePlaceholder.verticalAlignment
            positioner.enabled = false
        }
    }

    Item {
        anchors {
            fill: parent
            topMargin: positioner.topMargin
            bottomMargin: positioner.bottomMargin
        }

        CompassPlaceholder {
            objectName: "settings"
            id: settingsPlaceholder

            positioner: parent
            opposite: capturePlaceholder
            horizontalAlignment: !globalSettings.reverseButtons ? Qt.AlignLeft : Qt.AlignRight
            verticalAlignment: globalSettings.settingsVerticalAlignment
        }


        CompassPlaceholder {
            objectName: "capture"
            id: capturePlaceholder

            positioner: parent
            opposite: settingsPlaceholder
            horizontalAlignment: !globalSettings.reverseButtons ? Qt.AlignRight : Qt.AlignLeft
            verticalAlignment: globalSettings.captureVerticalAlignment
        }
    }
}
