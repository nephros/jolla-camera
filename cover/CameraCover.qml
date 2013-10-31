import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0

CoverBackground {
    Grid {
        columns: 2
        spacing: Theme.paddingLarge + Theme.paddingLarge
        anchors {
            fill: parent
            margins: Theme.paddingLarge + Theme.paddingMedium
        }

        CoverIcon { icon: Settings.captureModeIcon(Settings.global.captureMode) }
        CoverIcon { icon: Settings.flashIcon(Settings.mode.flash) }
        CoverIcon { icon: Settings.whiteBalanceIcon(Settings.mode.whiteBalance) }
        CoverIcon { icon: Settings.focusDistanceIcon(Settings.mode.focusDistance) }
    }
}
