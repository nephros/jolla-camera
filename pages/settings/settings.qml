import QtQuick 2.0
import QtMultimedia 5.0
import com.jolla.camera 1.0

SettingsBase {
    property alias mode: modeSettings
    property alias global: globalSettings
    property alias resolutions: resolutionSettings

    property GConfSettings _global: GConfSettings {
        id: globalSettings

        path: "/apps/jolla-camera"
        property string shootingMode: "automatic"
        property int aspectRatio: CameraExtensions.AspectRatio_16_9
        property int settingsVerticalAlignment: Qt.AlignVCenter
        property int captureVerticalAlignment: Qt.AlignVCenter
        property bool reverseButtons: false

        property string audioCodec
        property string videoCodec: "video/mpeg, mpegversion=(int)4"
        property string mediaContainer: "video/quicktime, variant=(string)iso"

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

        GConfSettings {
            path: modeSettings.face == CameraExtensions.Back
                        ? "resolutions/back"
                        : "resolutions/front"

            GConfSettings {
                id: resolutionSettings
                path: globalSettings.aspectRatio == CameraExtensions.AspectRatio_16_9
                        ? "16_9"
                        : "4_3"
                property size image: "1280x720"     // Last gasp defaults, the real value comes
                property size video: "1280x720"     // from the schema or an explicity overridden value.
            }
        }
    }
}
