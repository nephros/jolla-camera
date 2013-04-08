import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

DockedPanel {
    id: panel

    property Camera camera
    property int mode: camera.captureMode
    property int _managedMode: Camera.Still

    property int status: camera.status

    width: panel.dock == Dock.Right ? theme.paddingSmall + theme.itemSizeExtraLarge : parent.width
    height: panel.dock == Dock.Bottom ? theme.paddingSmall + theme.itemSizeExtraLarge : parent.height

    onModeChanged: open = false
    onExpandedChanged: reopenTimer.restart()

    onStatusChanged: {
        if (status != Camera.Capturing && status != Camera.Recording) {
            captureButton.checked = false
        }
    }

    Timer {
        id: reopenTimer

        interval: 50
        onTriggered: {
            if (!expanded && _managedMode != mode) {
                _managedMode = mode
                panel.open = true
            }
        }
    }

    Switch {
        id: captureButton
        objectName: "captureButton"

        anchors {
            horizontalCenter: parent.horizontalCenter
            horizontalCenterOffset: panel.dock == Dock.Right ? -theme.paddingSmall : 0
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: panel.dock == Dock.Bottom ? -theme.paddingSmall : 0
        }

        enabled: !checked

        onClicked: {
            if (camera.status != Camera.Previewing) {
                camera.stop()
            } else if (panel._managedMode == Camera.Still) {
                camera.capture()
            } else if (panel._managedMode == Camera.Video) {
                camera.record()
            }
        }
    }
}
