import QtQuick 2.0
import QtMultimedia 5.0
import com.jolla.dconf.schema 1.0

Schema {
    path: "/apps/jolla-camera"

    property string cameraDevice: "primary"
    property string captureMode: "image"
    property int portraitCaptureButtonLocation: 3
    property int landscapeCaptureButtonLocation: 4
    property bool saveLocationInfo: false

    ModeSchema {
        path: "primary/image"
        captureMode: Camera.CaptureStillImage
        focusDistance: Camera.FocusContinuous
        flash: Camera.FlashAuto

        imageResolution: "3264x1840"

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
    ModeSchema {
        path: "primary/video"

        captureMode: Camera.CaptureVideo
        focusDistance: Camera.FocusContinuous
        flash: Camera.FlashOff
        videoResolution: "1920x1088"
        focusDistanceValues: [
            Camera.FocusInfinity,
            Camera.FocusContinuous
        ]
        flashValues: [ Camera.FlashOff/*, Camera.FlashTorch*/ ]
    }
    ModeSchema {
        path: "secondary/image"
        captureMode: Camera.CaptureStillImage
        imageResolution: "1280x720"
        videoResolution: "1280x720"
    }
    ModeSchema {
        path: "secondary/video"
        captureMode: Camera.CaptureVideo
        imageResolution: "1280x720"
        videoResolution: "1280x720"
    }
}
