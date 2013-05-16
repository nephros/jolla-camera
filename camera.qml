import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0
import "pages"
import "cover"

ApplicationWindow {
    id: window
    cover: Component{
        CameraCover {
        }
    }

    initialPage: Component {
        CameraPage {
            pageStack: window.pageStack
            windowActive: window.applicationActive
        }
    }

    GConfSettings {
        id: globalSettings
        path: "/apps/jolla-camera"
        property string shootingMode: "automatic"
        property int aspectRatio: Settings.AspectRatio_16_9
        property int settingsVerticalAlignment: Qt.AlignVCenter
        property int captureVerticalAlignment: Qt.AlignVCenter
        property bool reverseButtons: false

        GConfSettings {
            id: modeSettings
            path: globalSettings.shootingMode

            property int iso: 0
            property int whiteBalance: CameraImageProcessing.WhiteBalanceAuto
            property int focusDistance: Camera.FocusAuto
            property int videoFocus: Camera.FocusAuto
            property int flash: Camera.FlashAuto
            property int exposureCompensation: 0
            property int exposureMode: 0
            property int meteringMode: Camera.MeteringMatrix
            property int timer: 0
            property int face: CameraExtensions.Back

            property bool isoConfigurable: true
            property bool whiteBalanceConfigurable: true
            property bool focusDistanceConfigurable: true
            property bool videoFocusConfigurable: true
            property bool flashConfigurable: true
            property bool exposureConfigurable: true
            property bool meteringModeConfigurable: true
            property bool timerConfigurable: true
        }
    }
}
