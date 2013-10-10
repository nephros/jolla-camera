import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0

Cover {
    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: Theme.rgba(Theme.highlightBackgroundColor, 0.6)
    }

    Grid {
        columns: 2
        spacing: Theme.paddingLarge
        anchors.centerIn: parent
        Image {
            // Scale down to match the size of the individual settings icons.
            width: referenceIcon.width; height: referenceIcon.height; fillMode: Image.PreserveAspectFit
            source: Settings.shootingModeIcon(Settings.global.shootingMode) + "?" + Theme.highlightDimmerColor
        }

        Image {
            width: referenceIcon.width; height: referenceIcon.height; fillMode: Image.PreserveAspectFit
            source: Settings.isoIcon(Settings.mode.iso) + "?" + Theme.highlightDimmerColor
        }

        Image {
            width: referenceIcon.width; height: referenceIcon.height; fillMode: Image.PreserveAspectFit
            source: Settings.timerIcon(Settings.mode.timer) + "?" + Theme.highlightDimmerColor
        }

        Item { // Placeholder item.
            width: 1; height: 1
        }

        Image {
            id: referenceIcon
            source: Settings.whiteBalanceIcon(Settings.mode.whiteBalance) + "?" + Theme.highlightDimmerColor
        }

        Image {
            source: Settings.flashIcon(Settings.mode.flash) + "?" + Theme.highlightDimmerColor
        }

        Image {
            source: Settings.meteringModeIcon(Settings.mode.meteringMode) + "?" + Theme.highlightDimmerColor
        }

        Image {
            width: referenceIcon.width; height: referenceIcon.height; fillMode: Image.PreserveAspectFit
            source: Settings.exposureIcon(Settings.mode.exposureConfigurable
                    ? Settings.mode.exposureCompensation
                    : 0) + "?" + Theme.highlightDimmerColor
        }
    }
}
