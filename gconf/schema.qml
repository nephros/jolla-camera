import QtQuick 2.0
import QtMultimedia 5.0
import com.jolla.gconf.schema 1.0
import com.jolla.camera 1.0

GConfSchema {
    path: "/apps/jolla-camera"
    GConfSchema {
        path: "shootingMode"
        owner: "jolla"
        type: GConfSchema.String
        defaultValue: "automatic"
        GConfDescription { locale: "C"; brief: "Current shooting mode" }
    }
    IntegerSchema {
        path: "aspectRatio"
        defaultValue: CameraExtensions.AspectRatio_16_9
    }
    IntegerSchema {
        path: "settingsVerticalAlignment"
        defaultValue: Qt.AlignVCenter
    }
    GConfSchema {
        path: "reverseButtons"
        owner: "jolla"
        type: GConfSchema.Bool
        defaultValue: false
        GConfDescription { locale: "C" }
    }
    IntegerSchema {
        path: "captureVerticalAlignment"
        defaultValue: Qt.AlignVCenter
    }
    AutomaticSchema {
        path: "automatic"
        exposureMode: Camera.ExposureAuto
    }
    ModeSchema {
        path: "program"
        exposureMode: Camera.ExposureManual
    }
    AutomaticSchema {
        path: "macro"
        exposureMode: Camera.ExposureSmallAperture
        focusDistance: Camera.MacroFocus
    }
    AutomaticSchema {
        path: "sports"
        exposureMode: Camera.ExposureSports
    }
    AutomaticSchema {
        path: "landscape"
        exposureMode: Camera.ExposureLargeAperture
    }
    AutomaticSchema {
        path: "portrait"
        exposureMode: Camera.ExposurePortrait
    }
    AutomaticSchema {
        path: "front-camera"
        face: CameraExtensions.Front
        flashConfigurable: false
    }
}
