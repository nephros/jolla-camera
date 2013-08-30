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
        focusDistance: Camera.FocusMacro
        focusDistanceConfigurable: false
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
        focusDistance: Camera.FocusInfinity
        flashConfigurable: false
        focusDistanceConfigurable: false
    }
    ResolutionSchema {
        path: "resolutions/back/16_9"
        image: "3264x1840"
        video: "1280x720"
    }
    ResolutionSchema {
        path: "resolutions/back/4_3"
        image: "3264x2448"
        video: "640x480"
    }
    ResolutionSchema {
        path: "resolutions/front/16_9"
        image: "1280x720"
        video: "1280x720"
    }

    ResolutionSchema {
        path: "resolutions/front/4_3"
        image: "1280x960"
        video: "640x480"
    }
}
