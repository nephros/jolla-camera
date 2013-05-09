import QtQuick 1.1
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0

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
        defaultValue: Settings.AspectRatio_16_9
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
}
