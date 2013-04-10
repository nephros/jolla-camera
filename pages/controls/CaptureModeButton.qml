import QtQuick 1.2
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

CircularButton {
    id: button

    property Camera camera

    diameter: theme.itemSizeMedium
    enabled: !switchAnimation.running

    Image {
        anchors.centerIn: parent

        source: button.camera.captureMode == Camera.Still
                ? "image://theme/icon-m-video"
                : "image://theme/icon-m-image"
    }

    onClicked: switchAnimation.start()

    SequentialAnimation {
        id: switchAnimation

        NumberAnimation {
            target: button
            property: "opacity"
            from: 1.0
            to: 0.0
        }

        ScriptAction {
            script: button.camera.captureMode = 1 - button.camera.captureMode
        }

        NumberAnimation {
            target: button
            property: "opacity"
            from: 0.0
            to: 1.0
        }
    }
}
