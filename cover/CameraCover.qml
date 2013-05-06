import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0
import "../pages/settings/SettingsIcons.js" as SettingsIcons

Cover {
    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: theme.rgba(theme.highlightBackgroundColor, 0.6)
    }

    Grid {
        columns: 2
        spacing: theme.paddingLarge
        anchors.centerIn: parent
        Image {
            // Scale down to match the size of the individual settings icons.
            width: referenceIcon.width; height: referenceIcon.height; fillMode: Image.PreserveAspectFit
            source: SettingsIcons.shootingMode(Settings, globalSettings.shootingMode) + "?" + theme.highlightDimmerColor
        }

        Image {
            width: referenceIcon.width; height: referenceIcon.height; fillMode: Image.PreserveAspectFit
            source: SettingsIcons.iso(modeSettings.iso) + "?" + theme.highlightDimmerColor
        }

        Image {
            width: referenceIcon.width; height: referenceIcon.height; fillMode: Image.PreserveAspectFit
            source: SettingsIcons.timer(modeSettings.timer) + "?" + theme.highlightDimmerColor
        }

        Item { // Placeholder item.
            width: 1; height: 1
        }

        Image {
            id: referenceIcon
            source: SettingsIcons.whiteBalance(CameraImageProcessing, modeSettings.whiteBalance) + "?" + theme.highlightDimmerColor
        }

        Image {
            source: SettingsIcons.flash(Camera, modeSettings.flash) + "?" + theme.highlightDimmerColor
        }

        Image {
            source: SettingsIcons.meteringMode(Camera, modeSettings.meteringMode) + "?" + theme.highlightDimmerColor
        }

        Image {
            width: referenceIcon.width; height: referenceIcon.height; fillMode: Image.PreserveAspectFit
            source: SettingsIcons.exposure(modeSettings.exposureConfigurable
                    ? settings.exposureCompensation
                    : 0) + "?" + theme.highlightDimmerColor
        }
    }
}
