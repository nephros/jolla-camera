import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

Item {
    id: slider

    property int alignment: Text.AlignRight
    property int valueCount_: Settings.mode.exposureCompensationValues.length
    property real divisionSize_: height/valueCount_
    property int value: Settings.mode.exposureCompensation

    onValueChanged: {
        if (!mouseArea.drag.active) {
            updateHandlePosition()
        }
    }

    Component.onCompleted: updateHandlePosition()

    function updateHandlePosition() {
        var index = Settings.mode.exposureCompensationValues.indexOf(value)
        handle.y = index * divisionSize_ + mouseArea.drag.minimumY
    }

    height: valueCount_ * (Theme.itemSizeSmall + Theme.paddingSmall)
    width: Theme.itemSizeMedium

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: 2
        y: divisionSize_/2
        height: parent.height-divisionSize_
    }

    Rectangle {
        id: handle
        color: "black"
        width: icon.width*0.8
        height: icon.height*0.8
        radius: Theme.paddingSmall/2
        anchors.horizontalCenter: parent.horizontalCenter

        Behavior on y {
            id: handleBehavior
            enabled: false
            NumberAnimation {
                id: handleAnimation
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        onYChanged: {
            if (mouseArea.drag.active) {
                var index = Math.floor((y - mouseArea.drag.minimumY - 1)/(mouseArea.drag.maximumY-mouseArea.drag.minimumY) * valueCount_)
                if (index >= 0) {
                    Settings.mode.exposureCompensation = Settings.mode.exposureCompensationValues[index]
                }
            }
        }

        MouseArea {
            id: mouseArea
            width: Theme.itemSizeMedium
            height: Theme.itemSizeMedium
            anchors.centerIn: icon

            drag {
                target: handle
                axis: Drag.YAxis
                minimumY: (divisionSize_-handle.height)/2
                maximumY: slider.height-(divisionSize_-handle.height/2)
                threshold: Theme.startDragDistance/2

                onActiveChanged: {
                    handleBehavior.enabled = !drag.active
                    if (!drag.active) {
                        updateHandlePosition()
                    }
                }
            }
        }
        Image {
            id: icon
            anchors.centerIn: parent
            source: "image://theme/icon-camera-exposure-compensation"
        }
    }

    Label {
        id: title
        x: alignment == Text.AlignRight ? -width+Theme.paddingSmall : parent.width-Theme.paddingSmall
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.itemSizeSmall

        color: Theme.highlightColor
        font {
            pixelSize: Theme.fontSizeExtraSmall
            bold: true
        }
        wrapMode: Text.WordWrap
        horizontalAlignment: alignment

        //% "Exposure compensation"
        text: qsTrId("jolla-camera-la-exposure_compensation")

        opacity: (mouseArea.drag.active || handleAnimation.running) ? 1.0 : 0.0
        Behavior on opacity { FadeAnimation {} }
    }

    Column {
        x: title.x
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        Repeater {
            model: Settings.mode.exposureCompensationValues
            delegate: Item {
                property bool selected: Settings.mode.exposureCompensation == modelData
                height: divisionSize_
                width: Theme.itemSizeSmall
                opacity: (mouseArea.drag.active || handleAnimation.running) && Settings.mode.exposureCompensation != 0 && selected ? 1.0 : 0.0
                Behavior on opacity { FadeAnimation {} }
                Rectangle {
                    width: Theme.itemSizeSmall
                    height: Theme.itemSizeSmall
                    radius: width/2
                    anchors.centerIn: parent
                    color: Theme.rgba(Theme.highlightDimmerColor, 0.4)
                    Image {
                        anchors.centerIn: parent
                        source: Settings.exposureIcon(modelData)
                    }
                }
            }
        }
    }
}
