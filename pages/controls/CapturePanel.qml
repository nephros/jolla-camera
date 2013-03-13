import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

DockedPanel {
    id: panel

    property Camera camera
    property int mode: camera.captureMode
    property int _managedMode: Camera.Still

    property int status: camera.status

    width: theme.paddingSmall + theme.itemSizeExtraLarge
    height: parent.height
    dock: Dock.Right

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
            horizontalCenterOffset: -theme.paddingSmall
            verticalCenter: parent.verticalCenter
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

    IconButton {
        objectName: "modeButton"

        anchors {
            horizontalCenter: parent.horizontalCenter
            horizontalCenterOffset: -theme.paddingSmall
            bottom: parent.bottom
            bottomMargin: theme.paddingLarge
        }

        icon.source: panel._managedMode == Camera.Still
                ? "image://theme/icon-m-image"
                : "image://theme/icon-m-video"

        onClicked: {
            if (panel.mode == Camera.Still) {
                camera.captureMode = Camera.Video
            } else if (panel.mode == Camera.Video) {
                camera.captureMode = Camera.Still
            }
        }
    }
}
