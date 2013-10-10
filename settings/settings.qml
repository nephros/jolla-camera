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
        property int aspectRatio: SettingsBase.AspectRatio_16_9
        property int settingsVerticalAlignment: Qt.AlignVCenter
        property int captureVerticalAlignment: Qt.AlignVCenter
        property bool reverseButtons: false
        property bool enableExtendedModes: false

        property int videoFocus: Camera.FocusAuto

        property string audioCodec: "audio/mpeg, mpegversion=(int)4"
        property string videoCodec: "video/mpeg, mpegversion=(int)4"
        property string mediaContainer: "video/quicktime, variant=(string)iso"

        GConfSettings {
            id: modeSettings
            path: globalSettings.shootingMode

            property int iso: 0
            property int whiteBalance: CameraImageProcessing.WhiteBalanceAuto
            property int focusDistance: Camera.FocusAuto
            property int flash: Camera.FlashAuto
            property int exposureCompensation: 0
            property int exposureMode: 0
            property int meteringMode: Camera.MeteringMatrix
            property int timer: 0
            property int face: SettingsBase.Back

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
            path: modeSettings.face == SettingsBase.Back
                        ? "resolutions/back"
                        : "resolutions/front"

            GConfSettings {
                id: resolutionSettings
                path: globalSettings.aspectRatio == SettingsBase.AspectRatio_16_9
                        ? "16_9"
                        : "4_3"
                property size image: "1280x720"     // Last gasp defaults, the real value comes
                property size video: "1280x720"     // from the schema or an explicity overridden value.
                property size viewfinder: "1280x720"
            }
        }
    }


    function shootingModeIcon(mode) {
        return "image://theme/icon-camera-" + mode
    }

    function exposureIcon(exposure) {
        // Exposure is value * 2 so it can be stored as an integer
        switch (exposure) {
        case -4: return "image://theme/icon-camera-ec-minus2"
        case -3: return "image://theme/icon-camera-ec-minus15"
        case -2: return "image://theme/icon-camera-ec-minus1"
        case -1: return "image://theme/icon-camera-ec-minus05"
        case 0:  return "image://theme/icon-camera-exposure-compensation"
        case 1:  return "image://theme/icon-camera-ec-plus05"
        case 2:  return "image://theme/icon-camera-ec-plus1"
        case 3:  return "image://theme/icon-camera-ec-plus15"
        case 4:  return "image://theme/icon-camera-ec-plus2"
        }
    }

    function timerIcon(timer) {
        return timer > 0
                ? "image://theme/icon-camera-timer-" + timer + "s"
                : "image://theme/icon-camera-timer"
    }

    function isoIcon(iso) {
        return iso > 0
                ? "image://theme/icon-camera-iso-" + iso
                : "image://theme/icon-camera-iso"
    }

    function meteringModeIcon(mode) {
        switch (mode) {
        case Camera.MeteringMatrix:  return "image://theme/icon-camera-metering-matrix"
        case Camera.MeteringAverage: return "image://theme/icon-camera-metering-weighted"
        case Camera.MeteringSpot:    return "image://theme/icon-camera-metering-spot"
        }
    }

    function flashIcon(flash) {
        switch (flash) {
        case Camera.FlashAuto:              return "image://theme/icon-camera-flash-automatic"
        case Camera.FlashOff:               return "image://theme/icon-camera-flash-off"
        case Camera.FlashOn:                return "image://theme/icon-camera-flash-on"
        case Camera.FlashRedEyeReduction:   return "image://theme/icon-camera-flash-redeye"
        }
    }

    function whiteBalanceIcon(balance) {
        switch (balance) {
        case CameraImageProcessing.WhiteBalanceAuto:        return "image://theme/icon-camera-wb-automatic"
        case CameraImageProcessing.WhiteBalanceSunlight:    return "image://theme/icon-camera-wb-sunny"
        case CameraImageProcessing.WhiteBalanceCloudy:      return "image://theme/icon-camera-wb-cloudy"
        case CameraImageProcessing.WhiteBalanceShade:       return "image://theme/icon-camera-wb-shade"
        case CameraImageProcessing.WhiteBalanceSunset:      return "image://theme/icon-camera-wb-sunset"
        case CameraImageProcessing.WhiteBalanceFluorescent: return "image://theme/icon-camera-wb-fluorecent"
        case CameraImageProcessing.WhiteBalanceTungsten:    return "image://theme/icon-camera-wb-tungsten"
        default: return "image://theme/icon-camera-wb-default"
        }
    }

    function focusDistanceIcon(focusDistance) {
        switch (focusDistance) {
        case Camera.FocusAuto:      return "image://theme/icon-camera-focus-auto"
        case Camera.FocusInfinity:  return "image://theme/icon-camera-focus-infinity"
        case Camera.FocusMacro:    return "image://theme/icon-camera-focus-macro"
        }
    }
}
