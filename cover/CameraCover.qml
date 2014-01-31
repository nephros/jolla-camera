import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera 1.0

CoverBackground {
    Grid {
        columns: 2
        columnSpacing: Theme.paddingLarge + Theme.paddingLarge
        rowSpacing: Theme.paddingLarge + Theme.paddingMedium
        anchors.centerIn: parent

        CoverIcon { icon: Settings.captureModeIcon(Settings.global.captureMode) }
        CoverIcon { icon: Settings.flashIcon(Settings.mode.flash) }
        CoverIcon { icon: Settings.whiteBalanceIcon(Settings.mode.whiteBalance) }
        CoverIcon { icon: Settings.focusDistanceIcon(Settings.mode.focusDistance) }
        CoverIcon { icon: Settings.isoIcon(Settings.mode.iso) }
        CoverIcon { icon: Settings.exposureIcon(Settings.mode.exposureCompensation) }
        CoverIcon { icon: Settings.timerIcon(Settings.mode.timer) }
        CoverIcon { icon: Settings.viewfinderGridIcon(Settings.mode.viewfinderGrid) }
    }
}
