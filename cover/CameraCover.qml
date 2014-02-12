import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera 1.0

CoverBackground {

    Image {
        id: captureModeIcon
        y: Theme.paddingLarge + Theme.paddingMedium
        source: Settings.captureModeCoverIcon(Settings.global.captureMode)
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Grid {
        anchors {
            top: captureModeIcon.bottom
            topMargin: Theme.paddingMedium
            horizontalCenter: parent.horizontalCenter
        }
        columns: 2
        columnSpacing: Theme.paddingLarge
        rowSpacing: Theme.paddingMedium

        CoverIcon { icon: Settings.flashIcon(Settings.mode.flash) }
        CoverIcon { icon: Settings.whiteBalanceIcon(Settings.mode.whiteBalance) }
        CoverIcon { icon: Settings.focusDistanceIcon(Settings.mode.focusDistance) }
        CoverIcon { icon: Settings.isoIcon(Settings.mode.iso) }
        CoverIcon { icon: Settings.viewfinderGridIcon(Settings.mode.viewfinderGrid) }
        CoverIcon { icon: Settings.timerIcon(Settings.mode.timer) }
    }
}

