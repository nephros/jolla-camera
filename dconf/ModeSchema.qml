import QtQml 2.0
import QtMultimedia 5.0

QtObject {
    property string path

    property int captureMode: Camera.CaptureStillImage
    property int flash: Camera.FlashOff
    property int exposureMode: Camera.ExposureManual
    property int meteringMode: Camera.MeteringMatrix
    property int timer: 0
    property string viewfinderGrid: "none"

    property string imageResolution
    property string videoResolution
    property int videoFrameRate: 30
    property string viewfinderResolution

    property int iso: 0
    property var isoValues: [ 0, 100, 200, 400 ]
    property var focusDistanceValues: [ Camera.FocusInfinity ]
    property var flashValues: [ Camera.FlashOff ]
    property var exposureModeValues: [
        Camera.ExposureManual,
        Camera.ExposurePortrait,
        Camera.ExposureNight,
        Camera.ExposureSports
    ]
    property var meteringModeValues: [
        Camera.MeteringMatrix,
        Camera.MeteringAverage,
        Camera.MeteringSpot
    ]
    property var viewfinderGridValues: [ "none", "thirds", "ambience" ]
}
