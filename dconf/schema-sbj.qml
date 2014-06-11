import QtQml 2.0
import QtMultimedia 5.0

Schema {

    PrimaryImageSchema {
        imageResolution_16_9: "3264x1840"
        viewfinderResolution_16_9: "960x540"
        resolutionText_16_9: "camera_settings-me-16-9-6m"

        imageResolution_4_3: "3264x2448"
        viewfinderResolution_4_3: "640x480"
        resolutionText_4_3: "camera_settings-me-4-3-8m"

        videoResolution: "1920x1088"
    }

    SecondaryImageSchema {
        imageResolution_16_9: "1280x720"
        viewfinderResolution_16_9: "960x540"
        resolutionText_16_9: "camera_settings-me-16-9-1m"

        imageResolution_4_3: "1600x1200"
        viewfinderResolution_4_3: "640x480"
        resolutionText_4_3: "camera_settings-me-4-3-2m"

        videoResolution: "1280x720"
    }

    PrimaryVideoSchema {
        imageResolution: "3264x1840"
        videoResolution: "1920x1088"
        viewfinderResolution: "960x540"
    }

    SecondaryVideoSchema {
        imageResolution: "1280x720"
        videoResolution: "1280x720"
        viewfinderResolution: "960x540"
    }
}
