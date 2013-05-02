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

    Image {
        id: modeIcon
        anchors {
            left: parent.left
            top: parent.top
            margins: theme.paddingLarge
        }
        source: SettingsIcons.shootingMode(Settings, settings.shootingMode) + "?" + theme.highlightDimmerColor
    }

    Image {
        id: isoIcon
        anchors {
            top: parent.top
            right: parent.right
            margins: theme.paddingLarge
        }
        source: SettingsIcons.iso(settings.effectiveIso) + "?" + theme.highlightDimmerColor
    }

    Image {
        anchors {
            top: modeIcon.bottom
            left: parent.left
            margins: theme.paddingLarge
        }
        source: SettingsIcons.timer(settings.effectiveTimer) + "?" + theme.highlightDimmerColor
    }

    Image {
        anchors {
            bottom: meteringIcon.top
            left: parent.left
            margins: theme.paddingLarge
        }
        source: SettingsIcons.whiteBalance(CameraImageProcessing, settings.effectiveWhiteBalance) + "?" + theme.highlightDimmerColor
    }

    Image {
        anchors {
            bottom: exposureIcon.top
            right: parent.right
            margins: theme.paddingLarge
        }
        source: SettingsIcons.flash(Camera, settings.effectiveFlash) + "?" + theme.highlightDimmerColor
    }

    Image {
        id: meteringIcon
        anchors {
            bottom: parent.bottom
            left: parent.left
            margins: theme.paddingLarge
        }
        source: SettingsIcons.meteringMode(Camera, settings.effectiveMeteringMode) + "?" + theme.highlightDimmerColor
    }

    Image {
        id: exposureIcon
        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: theme.paddingLarge
        }
        source: SettingsIcons.exposure(!(settings.shootingModeProperties & Settings.Exposure)
                ? settings.exposureCompensation
                : 0) + "?" + theme.highlightDimmerColor
    }
}
