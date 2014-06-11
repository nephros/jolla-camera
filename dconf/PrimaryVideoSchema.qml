import QtQml 2.0
import QtMultimedia 5.0

ModeSchema {
    path: "primary/video"

    captureMode: Camera.CaptureVideo
    focusDistance: Camera.FocusContinuous
    flash: Camera.FlashOff
    focusDistanceValues: [
        Camera.FocusInfinity,
        Camera.FocusContinuous
    ]
    flashValues: [ Camera.FlashOff/*, Camera.FlashTorch*/ ]
}
