// SPDX-FileCopyrightText: 2014 - 2017 Jolla Ltd.
// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

import QtQml 2.0
import QtMultimedia 5.0

ModeSchema {
    property string imageResolution_4_3
    property string imageResolution_16_9
    property string viewfinderResolution_4_3
    property string viewfinderResolution_16_9

    captureMode: Camera.CaptureStillImage
    imageResolution: imageResolution_16_9
    viewfinderResolution: viewfinderResolution_16_9
}
