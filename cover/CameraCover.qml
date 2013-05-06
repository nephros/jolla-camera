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
            source: SettingsIcons.shootingMode(Settings, settings.shootingMode) + "?" + theme.highlightDimmerColor
        }

        Image {
            width: referenceIcon.width; height: referenceIcon.height; fillMode: Image.PreserveAspectFit
            source: SettingsIcons.iso(settings.effectiveIso) + "?" + theme.highlightDimmerColor
        }

        Image {
            width: referenceIcon.width; height: referenceIcon.height; fillMode: Image.PreserveAspectFit
            source: SettingsIcons.timer(settings.effectiveTimer) + "?" + theme.highlightDimmerColor
        }

        Item { // Placeholder item.
            width: 1; height: 1
        }

        Image {
            id: referenceIcon
            source: SettingsIcons.whiteBalance(CameraImageProcessing, settings.effectiveWhiteBalance) + "?" + theme.highlightDimmerColor
        }

        Image {
            source: SettingsIcons.flash(Camera, settings.effectiveFlash) + "?" + theme.highlightDimmerColor
        }

        Image {
            source: SettingsIcons.meteringMode(Camera, settings.effectiveMeteringMode) + "?" + theme.highlightDimmerColor
        }

        Image {
            width: referenceIcon.width; height: referenceIcon.height; fillMode: Image.PreserveAspectFit
            source: SettingsIcons.exposure(!(settings.shootingModeProperties & Settings.Exposure)
                    ? settings.exposureCompensation
                    : 0) + "?" + theme.highlightDimmerColor
        }
    }
}
