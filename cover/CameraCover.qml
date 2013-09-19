import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0
import "../pages/settings/SettingsIcons.js" as SettingsIcons

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
            source: SettingsIcons.shootingMode(Settings.global.shootingMode) + "?" + Theme.highlightDimmerColor
        }

        Image {
            width: referenceIcon.width; height: referenceIcon.height; fillMode: Image.PreserveAspectFit
            source: SettingsIcons.iso(Settings.mode.iso) + "?" + Theme.highlightDimmerColor
        }

        Image {
            width: referenceIcon.width; height: referenceIcon.height; fillMode: Image.PreserveAspectFit
            source: SettingsIcons.timer(Settings.mode.timer) + "?" + Theme.highlightDimmerColor
        }

        Item { // Placeholder item.
            width: 1; height: 1
        }

        Image {
            id: referenceIcon
            source: SettingsIcons.whiteBalance(CameraImageProcessing, Settings.mode.whiteBalance) + "?" + Theme.highlightDimmerColor
        }

        Image {
            source: SettingsIcons.flash(Camera, Settings.mode.flash) + "?" + Theme.highlightDimmerColor
        }

        Image {
            source: SettingsIcons.meteringMode(Camera, Settings.mode.meteringMode) + "?" + Theme.highlightDimmerColor
        }

        Image {
            width: referenceIcon.width; height: referenceIcon.height; fillMode: Image.PreserveAspectFit
            source: SettingsIcons.exposure(Settings.mode.exposureConfigurable
                    ? Settings.mode.exposureCompensation
                    : 0) + "?" + Theme.highlightDimmerColor
        }
    }
}
