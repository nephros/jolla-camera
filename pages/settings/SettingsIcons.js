

function shootingMode(Settings, mode) {
    return "image://theme/icon-camera-" + mode
}

function exposure(exposure) {
    // Exposure is value * 2 so it can be stored as an integer
    switch (exposure) {
    case -4: return "image://theme/icon-camera-ec-minus2"
    case -3: return "image://theme/icon-camera-ec-minus15"
    case -2: return "image://theme/icon-camera-ec-minus1"
    case -1: return "image://theme/icon-camera-ec-minus05"
    case 0:  return "image://theme/icon-camera-exposure-compensation"
    case 1:  return "image://theme/icon-camera-ec-plus05"
    case 2:  return "image://theme/icon-camera-ec-plus1"
    case 3:  return "image://theme/icon-camera-ec-plus15"
    case 4:  return "image://theme/icon-camera-ec-plus2"
    }
}

function timer(timer) {
    return timer > 0
            ? "image://theme/icon-camera-timer-" + timer + "s"
            : "image://theme/icon-camera-timer"
}

function iso(iso) {
    return iso > 0
            ? "image://theme/icon-camera-iso-" + iso
            : "image://theme/icon-camera-iso"
}

function meteringMode(Camera, mode) {
    switch (mode) {
    case Camera.MeteringMatrix:  return "image://theme/icon-camera-metering-matrix"
    case Camera.MeteringAverage: return "image://theme/icon-camera-metering-weighted"
    case Camera.MeteringSpot:    return "image://theme/icon-camera-metering-spot"
    }
}

function flash(Camera, flash) {
    switch (flash) {
    case Camera.FlashAuto:              return "image://theme/icon-camera-flash"
    case Camera.FlashOff:               return "image://theme/icon-camera-flash-off"
    case Camera.FlashOn:                return "image://theme/icon-camera-flash-on"
    case Camera.FlashRedEyeReduction:   return "image://theme/icon-camera-flash-redeye"
    }
}

function whiteBalance(CameraImageProcessing, balance) {
    switch (balance) {
    case CameraImageProcessing.WhiteBalanceAuto:        return "image://theme/icon-camera-wb-automatic"
    case CameraImageProcessing.WhiteBalanceSunlight:    return "image://theme/icon-camera-wb-sunny"
    case CameraImageProcessing.WhiteBalanceCloudy:      return "image://theme/icon-camera-wb-cloudy"
    case CameraImageProcessing.WhiteBalanceShade:       return "image://theme/icon-camera-wb-shade"
    case CameraImageProcessing.WhiteBalanceSunset:      return "image://theme/icon-camera-wb-sunset"
    case CameraImageProcessing.WhiteBalanceFluorescent: return "image://theme/icon-camera-wb-fluorecent"
    case CameraImageProcessing.WhiteBalanceTungsten:    return "image://theme/icon-camera-wb-tungsten"
    default: return "image://theme/icon-camera-wb-default"
    }
}

