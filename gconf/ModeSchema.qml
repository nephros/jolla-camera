import QtQuick 2.0
import QtMultimedia 5.0
import com.jolla.gconf.schema 1.0

GConfSchema {
    owner: "jolla"

    property alias captureMode: captureModeSchema.defaultValue
    property alias iso: isoSchema.defaultValue
    property alias whiteBalance: wbSchema.defaultValue
    property alias focusDistance: fdSchema.defaultValue
    property alias flash: flashSchema.defaultValue
    property alias exposureCompensation: ecSchema.defaultValue
    property alias exposureMode: exposureSchema.defaultValue
    property alias meteringMode: meteringSchema.defaultValue
    property alias timer: timerSchema.defaultValue

    property alias imageResolution: imageResolutionSchema.defaultValue
    property alias videoResolution: videoResolutionSchema.defaultValue
    property alias viewfinderResolution: viewfinderResolutionSchema.defaultValue

    property alias isoValues: isoValuesSchema.defaultValue
    property alias whiteBalanceValues: wbValuesSchema.defaultValue
    property alias focusDistanceValues: fdValuesSchema.defaultValue
    property alias flashValues: flashValuesSchema.defaultValue
    property alias exposureCompensationValues: ecValuesSchema.defaultValue
    property alias exposureModeValues: exposureValuesSchema.defaultValue
    property alias meteringModeValues: meteringValuesSchema.defaultValue
    property alias timerValues: timerValuesSchema.defaultValue

    IntegerSchema { id: captureModeSchema; path: "captureMode";       defaultValue: Camera.CaptureStillImage }
    IntegerSchema { id: isoSchema;      path: "iso";                  defaultValue: 0 }
    IntegerSchema { id: wbSchema;       path: "whiteBalance";         defaultValue: CameraImageProcessing.WhiteBalanceAuto }
    IntegerSchema { id: fdSchema;       path: "focusDistance";        defaultValue: Camera.FocusInfinity }
    IntegerSchema { id: flashSchema;    path: "flash";                defaultValue: Camera.FlashOff }
    IntegerSchema { id: ecSchema;       path: "exposureCompensation"; defaultValue: 0 }
    IntegerSchema { id: exposureSchema; path: "exposureMode";         defaultValue: Camera.ExposureAuto }
    IntegerSchema { id: meteringSchema; path: "meteringMode";         defaultValue: Camera.MeteringMatrix }
    IntegerSchema { id: timerSchema;    path: "timer";                defaultValue: 0 }

    ResolutionSchema { id: imageResolutionSchema; path: "imageResolution" }
    ResolutionSchema { id: videoResolutionSchema; path: "videoResolution" }
    ResolutionSchema { id: viewfinderResolutionSchema; path: "viewfinderResolution"; defaultValue: "768x432" }

    IntegerListSchema {
        id: isoValuesSchema
        path: "iso"
        defaultValue: [ 0, 100, 200, 400, 800, 1600 ]
    }
    IntegerListSchema {
        id: wbValuesSchema
        path: "whiteBalanceValues"
        defaultValue: [
            CameraImageProcessing.WhiteBalanceAuto,
            CameraImageProcessing.WhiteBalanceCloudy,
            CameraImageProcessing.WhiteBalanceSunlight,
            CameraImageProcessing.WhiteBalanceFluorescent,
            CameraImageProcessing.WhiteBalanceTungsten
        ]
    }
    IntegerListSchema {
        id: fdValuesSchema
        path: "focusDistanceValues"
        defaultValue: [ Camera.FocusInfinity ]
    }
    IntegerListSchema {
        id: flashValuesSchema
        path: "flashValues"
        defaultValue: [ Camera.FlashOff ]
    }
    IntegerListSchema {
        id: ecValuesSchema
        path: "exposureCompensationValues"
        defaultValue: 0
    }
    IntegerListSchema {
        id: exposureValuesSchema
        path: "exposureModeValues"
        defaultValue: [ Camera.ExposureAuto ]
    }
    IntegerListSchema {
        id: meteringValuesSchema;
        path: "meteringModeValues"
        defaultValue: [
            Camera.MeteringMatrix,
            Camera.MeteringAverage,
            Camera.MeteringSpot
        ]
    }
    IntegerListSchema {
        id: timerValuesSchema
        path: "timerValues"
        defaultValue: [ 0, 3, 5, 15, 20 ]
    }
}
