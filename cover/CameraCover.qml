import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import org.nemomobile.thumbnailer 1.0

CoverBackground {
    id: cover

    property int coverIndex: galleryActive
                             ? galleryIndex
                             : captureModel.count - 1

    onCoverIndexChanged: {
        repositionTimer.restart()
    }

    Timer {
        id: repositionTimer
        interval: 1
        running: true // for initial positioning
        onTriggered: {
            list.positionViewAtIndex(coverIndex, ListView.SnapPosition)
        }
    }

    ListView {
        id: list

        width: Math.floor(2 * parent.width / 3)
        height: Math.floor(2 * parent.height / 3)
        anchors {
            centerIn: parent
            // Paddings ignored on purpose from the offset calculation:
            verticalCenterOffset: galleryActive ? settingsBar.height / 2 : 0
        }

        displayMarginBeginning: galleryActive ? width : 0
        displayMarginEnd: galleryActive ? width : 0

        interactive: false
        model: captureModel
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem

        delegate: Item {
            width: list.width
            height: list.height
            Thumbnail {
                source: model.url
                mimeType: model.mimeType
                width: galleryActive
                       ? (index === coverIndex ? parent.width : 0.8 * parent.width)
                       : cover.width
                height: galleryActive
                        ? (index === coverIndex ? parent.height : 0.8 * parent.height)
                        : cover.height
                visible: galleryActive || index === coverIndex
                anchors.centerIn: parent
                smooth: true
                sourceSize.width: width
                sourceSize.height: height
                clip: true
            }
        }
    }

    Rectangle {
        width: parent.width
        height: settingsBar.height + 2 * Theme.paddingMedium

        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.rgba("black", 0.7) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    Row {
        id: settingsBar
        anchors {
            top: parent.top
            topMargin: Theme.paddingMedium
            horizontalCenter: parent.horizontalCenter
        }

        CoverIcon {
            icon: Settings.captureModeIcon(Settings.global.captureMode)
        }
        CoverIcon {
            icon: Settings.mode.flashValues.length > 1
                  ? Settings.flashIcon(Settings.mode.flash)
                  : Settings.isoIcon(Settings.mode.iso)
        }
        CoverIcon {
            icon: Settings.whiteBalanceIcon(Settings.mode.whiteBalance)
        }
        CoverIcon {
            icon: Settings.focusDistanceIcon(Settings.mode.focusDistance)
        }
    }

    Item {
        // "Focus indicator"
        width: Math.floor(cover.width / 2)
        height: width
        anchors.centerIn: parent
        visible: !galleryActive

        Rectangle {
            anchors.fill: parent
            border {
                width: 2
                color: "black"
            }
            color: "transparent"
        }
        Rectangle {
            anchors {
                fill: parent
                margins: 1
            }
            opacity: 0.6
            border {
                width: 3
                color: Theme.primaryColor
            }
            color: "transparent"
        }
    }
}
