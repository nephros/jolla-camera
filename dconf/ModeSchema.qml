// SPDX-FileCopyrightText: 2014 - 2021 Jolla Ltd.
// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

import QtQml 2.0
import QtMultimedia 5.0

QtObject {
    property string path

    property int captureMode: Camera.CaptureStillImage
    property int flash: Camera.FlashOff
    property int exposureMode: Camera.ExposureManual
    property int meteringMode: Camera.MeteringMatrix
    property int timer: 0

    property string imageResolution
    property string videoResolution
    property string viewfinderResolution

    property int iso: 0
}
