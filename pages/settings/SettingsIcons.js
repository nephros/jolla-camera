

function shootingMode(Settings, mode) {
    switch (mode) {
    case Settings.Auto:         return "image://theme/icon-camera-automatic"
    case Settings.Program:      return "image://theme/icon-camera-program"
    case Settings.Macro:        return "image://theme/icon-camera-macro"
    case Settings.Sports:       return "image://theme/icon-camera-sports"
    case Settings.Landscape:    return "image://theme/icon-camera-landscape"
    case Settings.Portrait:     return "image://theme/icon-camera-portrait"
    }
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
    switch (timer) {
    case 0:  return "image://theme/icon-camera-timer"
    case 3:  return "image://theme/icon-camera-timer-3s"
    case 15: return "image://theme/icon-camera-timer-15s"
    case 20: return "image://theme/icon-camera-timer-20s"
    }
}

function iso(iso) {
    switch (iso) {
    case 0:    return "image://theme/icon-camera-iso" // automatic
    case 100:  return "image://theme/icon-camera-iso-100"
    case 200:  return "image://theme/icon-camera-iso-200"
    case 400:  return "image://theme/icon-camera-iso-400"
    case 800:  return "image://theme/icon-camera-iso-800"
    case 1600: return "image://theme/icon-camera-iso-1600"
    }
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

