// SPDX-FileCopyrightText: 2014 - 2017 Jolla Ltd.
// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

import QtQml 2.0
import QtMultimedia 5.0

Schema {

    PrimaryImageSchema {
        imageResolution_16_9: "3264x1840"
        viewfinderResolution_16_9: "960x540"

        imageResolution_4_3: "3264x2448"
        viewfinderResolution_4_3: "640x480"

        videoResolution: "1920x1088"
    }

    SecondaryImageSchema {
        imageResolution_16_9: "1280x720"
        viewfinderResolution_16_9: "960x540"

        imageResolution_4_3: "1600x1200"
        viewfinderResolution_4_3: "640x480"

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
