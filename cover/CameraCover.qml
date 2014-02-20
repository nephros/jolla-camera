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

    CoverIcon {
        anchors { left: captureModeIcon.left; bottom: focusIcon.top; bottomMargin: Theme.paddingMedium }
        icon: Settings.flashIcon(Settings.mode.flash)
    }
    CoverIcon {
        anchors { right: captureModeIcon.right; bottom: isoIcon.top; bottomMargin: Theme.paddingMedium }
        icon: Settings.whiteBalanceIcon(Settings.mode.whiteBalance)
    }
    CoverIcon {
        id: focusIcon
        anchors { left: captureModeIcon.left; bottom: exposureIcon.top; bottomMargin: Theme.paddingMedium }
        icon: Settings.focusDistanceIcon(Settings.mode.focusDistance)
    }
    CoverIcon {
        id: isoIcon
        anchors { right: captureModeIcon.right; bottom: exposureIcon.top; bottomMargin: Theme.paddingMedium }
        icon: Settings.isoIcon(Settings.mode.iso)
    }

    CoverIcon {
        id: exposureIcon
        icon: {
            switch (Settings.mode.exposureCompensation) {
            case -4: return "image://theme/graphics-cover-camera-exposure2m"
            case -2: return "image://theme/graphics-cover-camera-exposure1m"
            case  0: return "image://theme/graphics-cover-camera-exposure0"
            case  2: return "image://theme/graphics-cover-camera-exposure1p"
            case  4: return "image://theme/graphics-cover-camera-exposure2p"
            }
        }

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom

            bottomMargin: Theme.paddingLarge + Theme.paddingMedium
        }
    }
}
