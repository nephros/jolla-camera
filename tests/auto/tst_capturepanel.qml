import QtQuickTest 1.0
import QtQuick 1.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import "scripts/Util.js" as Util

Item {
    id: main

    width: 640
    height: 480

    CapturePanel {
        id: panel

        camera: Camera {
            id: camera
        }
    }

    TestCase {
        when: windowShown

        function init() {
            panel._managedMode = Camera.Still
            camera.captureMode = Camera.Still
            panel.show(true)
        }

        function test_mode() {
            var modeButton = Util.findItemByName(panel, "modeButton")
            verify(modeButton != undefined)

            compare(camera.captureMode, Camera.Still)
            compare(panel._managedMode, Camera.Still)
            compare(panel.x , main.width - panel.width)
            compare(modeButton.icon.source, "image://theme/icon-m-image")

            modeButton.clicked(null)
            compare(camera.captureMode, Camera.Video)
            compare(panel._managedMode, Camera.Still)
            tryCompare(panel, "_managedMode", Camera.Video)
            tryCompare(panel, "x", main.width - panel.width) // wait for the panel to reopen.
            compare(modeButton.icon.source, "image://theme/icon-m-video")

            modeButton.clicked(null)
            compare(camera.captureMode, Camera.Still)
            compare(panel._managedMode, Camera.Video)
            tryCompare(panel, "_managedMode", Camera.Still)
            tryCompare(panel, "x", main.width - panel.width) // wait for the panel to reopen.
            compare(modeButton.icon.source, "image://theme/icon-m-image")
        }
    }
}
