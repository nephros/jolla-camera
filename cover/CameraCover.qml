import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0
import "../pages/settings/SettingsIcons.js" as SettingsIcons

Cover {
    anchors.fill: parent

    CoverBackground {
    }

    Image {
        id: modeIcon
        anchors {
            left: parent.left
            top: parent.top
            margins: theme.paddingLarge
        }
        source: SettingsIcons.shootingMode(Settings, settings.shootingMode)
    }

    Image {
        id: isoIcon
        anchors {
            top: parent.top
            right: parent.right
            margins: theme.paddingLarge
        }
        source: SettingsIcons.iso(settings.effectiveIso)
    }

    Image {
        anchors {
            top: modeIcon.bottom
            left: parent.left
            margins: theme.paddingLarge
        }
        source: SettingsIcons.timer(settings.effectiveTimer)
    }

    Image {
        anchors {
            bottom: meteringIcon.top
            left: parent.left
            margins: theme.paddingLarge
        }
        source: SettingsIcons.whiteBalance(CameraImageProcessing, settings.effectiveWhiteBalance)
    }

    Image {
        anchors {
            bottom: exposureIcon.top
            right: parent.right
            margins: theme.paddingLarge
        }
        source: SettingsIcons.flash(Camera, settings.effectiveFlash)
    }

    Image {
        id: meteringIcon
        anchors {
            bottom: parent.bottom
            left: parent.left
            margins: theme.paddingLarge
        }
        source: SettingsIcons.meteringMode(Camera, settings.effectiveMeteringMode)
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
                : 0)
    }
}
