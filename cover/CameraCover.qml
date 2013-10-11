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
        CoverIcon { icon: Settings.captureModeIcon(Settings.captureMode) }
        CoverIcon { icon: Settings.isoIcon(Settings.mode.iso) }
        CoverIcon { icon: Settings.timerIcon(Settings.mode.timer) }
        CoverIcon { icon: Settings.focusDistanceIcon(Settings.mode.focusDistance) }
        CoverIcon { icon: Settings.whiteBalanceIcon(Settings.mode.whiteBalance) }
        CoverIcon { icon: Settings.flashIcon(Settings.mode.flash) }
        CoverIcon { icon: Settings.meteringModeIcon(Settings.mode.meteringMode) }
        CoverIcon { icon: Settings.exposureIcon(Settings.mode.exposureCompensation) }
    }
}
