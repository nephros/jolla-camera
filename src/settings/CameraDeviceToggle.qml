import QtQuick 2.6
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

SilicaItem {
    id: root

    readonly property int currentIndex: {
        if (model) {
            for (var i = 0; i < model.length; i++) {
                var item = model[i]
                if (Settings.deviceId === item.deviceId) {
                    return i
                }
            }
        }
        return -1
    }
    property var model
    signal clicked

    onClicked: Settings.deviceId = model[(currentIndex + 1) % model.length].deviceId
    highlighted: mouseArea.pressed && mouseArea.containsMouse
    width: Theme.itemSizeExtraSmall
    height: Theme.itemSizeExtraSmall

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: root.clicked()
    }

    Rectangle {
        border {
            width: Theme._lineWidth
            color: root.highlighted ? Theme.highlightColor : Theme.primaryColor
        }

        radius: width/2
        anchors.fill: parent
        color: "transparent"
    }

    Label {
        // TODO: Don't hardcode these values
        text: currentIndex === 0 ? "1.0"
                                 : currentIndex === 1 ? "2.0" : "0.6"
        color: root.highlighted ? Theme.highlightColor : Theme.primaryColor
        anchors.centerIn: parent
    }
}
