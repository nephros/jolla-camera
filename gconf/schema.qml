import QtQuick 2.0
import QtMultimedia 5.0
import com.jolla.gconf.schema 1.0
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
    IntegerSchema {
        path: "videoFocus"
        defaultValue: Camera.FocusAuto
    }
    IntegerSchema {
        path: "captureButtonLocation"
        defaultValue: 5
    }
    ModeSchema {
        path: "main-camera"
        exposureMode: Camera.ExposureAuto
    }
    ModeSchema {
        path: "front-camera"
        face: Settings.Front
        focusDistance: Camera.FocusInfinity
        flash: Camera.FlashOff
        flashConfigurable: false
        focusDistanceConfigurable: false
    }
    ResolutionSchema {
        path: "resolutions/back/16_9"
        image: "3264x1840"
        video: "1920x1088"
        viewfinder: "768x432"
    }
    ResolutionSchema {
        path: "resolutions/back/4_3"
        image: "3264x2448"
        video: "640x480"
        viewfinder: "640x480"
    }
    ResolutionSchema {
        path: "resolutions/front/16_9"
        image: "1280x720"
        video: "1280x720"
        viewfinder: "768x432"
    }

    ResolutionSchema {
        path: "resolutions/front/4_3"
        image: "1280x960"
        video: "640x480"
        viewfinder: "640x480"
    }
}
