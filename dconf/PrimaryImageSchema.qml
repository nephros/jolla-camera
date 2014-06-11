import QtQml 2.0
import QtMultimedia 5.0

ImageSchema {
    path: "primary/image"
    captureMode: Camera.CaptureStillImage
    focusDistance: Camera.FocusContinuous
    flash: Camera.FlashAuto

    focusDistanceValues: [
        Camera.FocusAuto,
        Camera.FocusInfinity,
        Camera.FocusContinuous
    ]
    flashValues: [
        Camera.FlashAuto,
        Camera.FlashOff,
        Camera.FlashOn
    ]
}
