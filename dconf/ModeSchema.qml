import QtQuick 2.0
import QtMultimedia 5.0
import com.jolla.dconf.schema 1.0

Schema {
    property int captureMode: Camera.CaptureStillImage
    property int iso: 0
    property int whiteBalance: CameraImageProcessing.WhiteBalanceAuto
    property int focusDistance: Camera.FocusInfinity
    property int flash: Camera.FlashOff
    property int exposureCompensation: 0
    property int exposureMode: Camera.ExposureAuto
    property int meteringMode: Camera.MeteringMatrix
    property int timer: 0
    property string viewfinderGrid: "none"

    property string imageResolution
    property string videoResolution
    property string viewfinderResolution: "960x540"

    property variant isoValues: [ 0, 100, 200, 400 ]
    property variant whiteBalanceValues: [
        CameraImageProcessing.WhiteBalanceAuto,
        CameraImageProcessing.WhiteBalanceCloudy,
        CameraImageProcessing.WhiteBalanceSunlight,
        CameraImageProcessing.WhiteBalanceFluorescent,
        CameraImageProcessing.WhiteBalanceTungsten
    ]
    property variant focusDistanceValues: [ Camera.FocusInfinity ]
    property variant flashValues: [ Camera.FlashOff ]
    property variant exposureCompensationValues: [ 4, 2, 0, -2, -4 ]
    property variant exposureModeValues: [ Camera.ExposureAuto ]
    property variant meteringModeValues: [
        Camera.MeteringMatrix,
        Camera.MeteringAverage,
        Camera.MeteringSpot
    ]
    property variant timerValues: [ 0, 3, 10, 15 ]
    property variant viewfinderGridValues: [ "none", "thirds", "ambience" ]
}
