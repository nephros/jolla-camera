import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0

Item {
    id: positioner

    property real topMargin
    property real bottomMargin

    property bool animating: settingsPlaceholder.animating || capturePlaceholder.animating
    readonly property bool swapping: settingsPlaceholder.swapping || capturePlaceholder.swapping

    onSwappingChanged: {
        if (!swapping) {
            _finish()
        }
    }

    function _finish() {
        Settings.global.reverseButtons = settingsPlaceholder.horizontalAlignment == Qt.AlignRight
        Settings.global.settingsVerticalAlignment = settingsPlaceholder.verticalAlignment
        Settings.global.captureVerticalAlignment = capturePlaceholder.verticalAlignment
        positioner.enabled = false
    }

    onEnabledChanged: {
        if (enabled) {
            settingsPlaceholder.effectiveHorizontalAlignment = settingsPlaceholder.horizontalAlignment
            capturePlaceholder.effectiveHorizontalAlignment = capturePlaceholder.horizontalAlignment
        }
    }


    Rectangle {
        color: Theme.highlightDimmerColor
        opacity: 0.6
        anchors.fill: parent
    }

    MouseArea {
        width: positioner.width
        height: positioner.height
        onClicked: positioner._finish()
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
            horizontalAlignment: !Settings.global.reverseButtons ? Qt.AlignLeft : Qt.AlignRight
            verticalAlignment: Settings.global.settingsVerticalAlignment
        }


        CompassPlaceholder {
            objectName: "capture"
            id: capturePlaceholder

            positioner: parent
            opposite: settingsPlaceholder
            horizontalAlignment: !Settings.global.reverseButtons ? Qt.AlignRight : Qt.AlignLeft
            verticalAlignment: Settings.global.captureVerticalAlignment
        }
    }
}
