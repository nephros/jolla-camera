import QtQml 2.0
import QtMultimedia 5.0

QtObject {
    property string path

    property int captureMode: Camera.CaptureStillImage
    property int iso: 0
    property int whiteBalance: CameraImageProcessing.WhiteBalanceAuto
    property int flash: Camera.FlashOff
    property int exposureCompensation: 0
    property int exposureMode: Camera.ExposureAuto
    property int meteringMode: Camera.MeteringMatrix
    property int timer: 0
    property string viewfinderGrid: "none"

    property string imageResolution
    property string videoResolution
    property string viewfinderResolution

    property var isoValues: [ 0, 100, 200, 400 ]
    property var whiteBalanceValues: [
        CameraImageProcessing.WhiteBalanceAuto,
        CameraImageProcessing.WhiteBalanceCloudy,
        CameraImageProcessing.WhiteBalanceSunlight,
        CameraImageProcessing.WhiteBalanceFluorescent,
        CameraImageProcessing.WhiteBalanceTungsten
    ]
    property var focusDistanceValues: [ Camera.FocusInfinity ]
    property var flashValues: [ Camera.FlashOff ]
    property var exposureCompensationValues: [ 4, 2, 0, -2, -4 ]
    property var exposureModeValues: [ Camera.ExposureAuto ]
    property var meteringModeValues: [
        Camera.MeteringMatrix,
        Camera.MeteringAverage,
        Camera.MeteringSpot
    ]
    property var timerValues: [ 0, 3, 10, 15 ]
    property var viewfinderGridValues: [ "none", "thirds", "ambience" ]
}
