import QtQml 2.0
import QtMultimedia 5.0

QtObject {
    id: schema

    property string path: "/apps/jolla-camera"

    property string deviceId: QtMultimedia.defaultCamera.deviceId
    property string captureMode: "image"
    property int portraitCaptureButtonLocation: 3
    property int landscapeCaptureButtonLocation: 4
    property bool saveLocationInfo: false
    property int exposureCompensation: 0
    property int whiteBalance: CameraImageProcessing.WhiteBalanceAuto
    property var exposureCompensationValues: [ 4, 3, 2, 1, 0, -1, -2, -3, -4 ]

    property list<QtObject> _modes
    default property alias modes: schema._modes
    property QtObject _dummy: QtObject {}

    Component.onCompleted: {
        var blacklist = [ "path", "modes", "_modes", "_dummy" ]
        for (var prop in _dummy) {
            blacklist.push(prop)
        }

        printValues('', schema, blacklist)

        for (var i = 0; i < modes.length; ++i) {
            print('')
            printValues(path, modes[i], blacklist)
        }

        Qt.quit()
    }

    function printValues(basePath, object, blacklist) {
        var path = object.path.charAt(0) == '/'
                ? object.path.slice(1)
                : (basePath + '/' + object.path).slice(1)

        print('[' + path + ']')

        for (var prop in object) {
            var value = object[prop]
            if (blacklist.indexOf(prop) == -1
                    && typeof(value) != "function"
                    && (typeof(value) != "string" || value != "")) {
                print(prop + '=' + toPrintable(value))
            }
        }
    }

    function toPrintable(value) {
        if (typeof(value) == "string") {
            return '\'' + value +'\''
        } else if (typeof(value) == "object") {
            var array = []
            for (var i = 0; i < value.length; ++i) {
                array.push(toPrintable(value[i]))
            }
            return '[' + array.join(', ') + ']'
        } else {
            return value
        }
    }
}
