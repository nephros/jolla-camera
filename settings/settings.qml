import QtQuick 2.0
import QtMultimedia 5.0
import com.jolla.camera.settings 1.0

SettingsBase {
    property alias mode: modeSettings
    property alias global: globalSettings

    property GConfSettings _global: GConfSettings {
        id: globalSettings

        path: "/apps/jolla-camera"

        property string cameraDevice: "primary"
        property string captureMode: "image"

        property int portraitCaptureButtonLocation: 4
        property int landscapeCaptureButtonLocation: 5

        property string audioCodec: "audio/mpeg, mpegversion=(int)4"
        property int audioSampleRate: 48000
        property string videoCodec: "video/mpeg, mpegversion=(int)4"
        property string mediaContainer: "video/quicktime, variant=(string)iso"

        GConfSettings {
            id: modeSettings
            path: globalSettings.cameraDevice + "/" + globalSettings.captureMode

            property int captureMode: Camera.CaptureStillImage

            property int iso: 0
            property int whiteBalance: CameraImageProcessing.WhiteBalanceAuto
            property int focusDistance: Camera.FocusInfinity
            property int flash: Camera.FlashOff
            property int exposureCompensation: 0
            property int exposureMode: 0
            property int meteringMode: Camera.MeteringMatrix
            property int timer: 0

            property size imageResolution: "1280x720"
            property size videoResolution: "1280x720"
            property size viewfinderResolution: "1280x720"

            property variant isoValues: [ 0 ]
            property variant whiteBalanceValues: [
                CameraImageProcessing.WhiteBalanceAuto,
                CameraImageProcessing.WhiteBalanceCloudy,
                CameraImageProcessing.WhiteBalanceSunlight,
                CameraImageProcessing.WhiteBalanceFluorescent,
                CameraImageProcessing.WhiteBalanceTungsten
            ]
            property variant focusDistanceValues: [ Camera.FocusInfinity ]
            property variant flashValues: [ Camera.FlashOff ]
            property variant exposureCompensationValues: [ 0 ]
            property variant exposureModeValues: [ Camera.ExposureAuto ]
            property variant meteringModeValues: [
                Camera.MeteringMatrix,
                Camera.MeteringAverage,
                Camera.MeteringSpot
            ]
            property variant timerValues: [ 0, 3, 5, 15, 20 ]
        }
    }

    function captureModeIcon(mode) {
        switch (mode) {
        case "image": return "image://theme/icon-camera-camera-mode"
        case "video": return "image://theme/icon-camera-video"
        default:  return ""
        }
    }

    function captureModeText(mode) {
        switch (mode) {
        //: "Still image capture mode"
        //% "Camera mode"
        case "image": return qsTrId("camera_settings-la-camera-mode")
        //: "Video recording mode"
        //% "Video mode"
        case "video":      return qsTrId("camera_settings-la-video-mode")
        default:  return ""
        }
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

    function flashText(flash) {
        switch (flash) {
        //: "Automatic camera flash mode"
        //% "Flash automatic"
        case Camera.FlashAuto:       return qsTrId("camera_settings-la-flash-auto")
        //: "Camera flash disabled"
        //% "Flash disabled"
        case Camera.FlashOff:   return qsTrId("camera_settings-la-flash-off")
        //: "Camera flash enabled"
        //% "Flash enabled"
        case Camera.FlashOn:      return qsTrId("camera_settings-la-flash-on")
        //: "Camera flash with red eye reduction"
        //% "Flash red eye"
        case Camera.FlashRedEyeReduction: return qsTrId("camera_settings-la-flash-redeye")
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

    function whiteBalanceText(balance) {
        switch (balance) {
        //: "Automatic white balance"
        //% "Automatic"
        case CameraImageProcessing.WhiteBalanceAuto:        return qsTrId("camera_settings-la-wb-automatic")
        //: "Sunny white balance"
        //% "Sunny"
        case CameraImageProcessing.WhiteBalanceSunlight:    return qsTrId("camera_settings-la-wb-sunny")
        //: "Cloudy white balance"
        //% "Cloudy"
        case CameraImageProcessing.WhiteBalanceCloudy:      return qsTrId("camera_settings-la-wb-cloudy")
        //: "Shade white balance"
        //% "Shade"
        case CameraImageProcessing.WhiteBalanceShade:       return qsTrId("camera_settings-la-wb-shade")
        //: "Sunset white balance"
        //% "Sunset"
        case CameraImageProcessing.WhiteBalanceSunset:      return qsTrId("camera_settings-la-wb-sunset")
        //: "Fluorecent white balance"
        //% "Fluorecent"
        case CameraImageProcessing.WhiteBalanceFluorescent: return qsTrId("camera_settings-la-wb-fluorecent")
        //: "Tungsten white balance"
        //% "Tungsten"
        case CameraImageProcessing.WhiteBalanceTungsten:    return qsTrId("camera_settings-la-wb-tungsten")
        default: return ""
        }
    }

    function focusDistanceIcon(focusDistance) {
        switch (focusDistance) {
        case Camera.FocusAuto:       return "image://theme/icon-camera-focus"
        case Camera.FocusInfinity:   return "image://theme/icon-camera-focus-infinity"
        case Camera.FocusMacro:      return "image://theme/icon-camera-focus-macro"
        case Camera.FocusContinuous: return "image://theme/icon-camera-focus-auto"
        }
    }

    function focusDistanceText(focusDistance) {
        switch (focusDistance) {
        //% "Tap to focus"
        case Camera.FocusAuto:       return qsTrId("camera_settings-la-focus-auto")
        //: "Infinite focus distance"
        //% "Infinity focus"
        case Camera.FocusInfinity:   return qsTrId("camera_settings-la-focus-infinity")
        //: "Macro/close up focus distance"
        //% "Macro focus"
        case Camera.FocusMacro:      return qsTrId("camera_settings-la-focus-macro")
        //: "Continuous auto focus"
        //% "Continuous"
        case Camera.FocusContinuous: return qsTrId("camera_settings-la-focus-continuous")
        }
    }
}
