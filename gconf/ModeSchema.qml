import QtQuick 1.1
import com.jolla.camera 1.0

GConfSchema {
    owner: "jolla"

    property alias iso: isoSchema.defaultValue
    property alias whiteBalance: wbSchema.defaultValue
    property alias focusDistance: fdSchema.defaultValue
    property alias videoFocus: vfSchema.defaultValue
    property alias flash: flashSchema.defaultValue
    property alias exposureCompensation: ecSchema.defaultValue
    property alias exposureMode: exposureSchema.defaultValue
    property alias meteringMode: meteringSchema.defaultValue
    property alias timer: timerSchema.defaultValue

    property alias isoConfigurable: isoConfig.defaultValue
    property alias whiteBalanceConfigurable: wbConfig.defaultValue
    property alias focusDistanceConfigurable: fdConfig.defaultValue
    property alias videoFocusConfigurable: vfConfig.defaultValue
    property alias flashConfigurable: flashConfig.defaultValue
    property alias exposureConfigurable: exposureConfig.defaultValue
    property alias meteringModeConfigurable: meteringConfig.defaultValue
    property alias timerConfigurable: timerConfig.defaultValue

    IntegerSchema { id: isoSchema;      path: "iso";                  defaultValue: 0 }
    IntegerSchema { id: wbSchema;       path: "whiteBalance";         defaultValue: CameraImageProcessing.WhiteBalanceAuto }
    IntegerSchema { id: fdSchema;       path: "focusDistance";        defaultValue: Camera.FocusAuto }
    IntegerSchema { id: vfSchema;       path: "videoFocus";           defaultValue: Camera.FocusAuto }
    IntegerSchema { id: flashSchema;    path: "flash";                defaultValue: Camera.FlashAuto }
    IntegerSchema { id: ecSchema;       path: "exposureCompensation"; defaultValue: 0 }
    IntegerSchema { id: exposureSchema; path: "exposureMode";         defaultValue: Camera.ExposureAuto }
    IntegerSchema { id: meteringSchema; path: "meteringMode";         defaultValue: Camera.MeteringMatrix }
    IntegerSchema { id: timerSchema;    path: "timer";                defaultValue: 0 }

    ConfigSchema { id: isoConfig;      path: "isoConfigurable" }
    ConfigSchema { id: wbConfig;       path: "whiteBalanceConfigurable" }
    ConfigSchema { id: fdConfig;       path: "focusDistanceConfigurable" }
    ConfigSchema { id: vfConfig;       path: "videoFocusConfigurable" }
    ConfigSchema { id: flashConfig;    path: "flashConfigurable" }
    ConfigSchema { id: exposureConfig; path: "exposureConfigurable" }
    ConfigSchema { id: meteringConfig; path: "meteringModeConfigurable" }
    ConfigSchema { id: timerConfig;    path: "timerConfigurable" }
}
