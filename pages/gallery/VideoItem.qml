import QtQuick 1.1
import Sailfish.Silica 1.0
import QtMultimediaKit 1.1
import org.nemomobile.thumbnailer 1.0

MouseArea {
    id: videoItem

    property Video player
    property bool active
    property url source
    property string mimeType

    onSourceChanged: console.log("Source", source)

    enabled: false

    onClicked: player.pause()

    onActiveChanged: {
        if (!active) {
            enabled = false
        }
    }

    Connections {
        target: videoItem.active ? videoItem.player : null

        onPositionChanged: positionSlider.value = videoItem.player.position / 1000
        onDurationChanged: positionSlider.maximumValue = videoItem.player.duration / 1000
        onStatusChanged: {
            switch (videoItem.player.status) {
            case Video.NoMedia:
            case Video.InvalidMedia:
            case Video.EndOfMedia:
                videoItem.enabled = false
                break
            default:
                break;
            }
        }
        onPlayingChanged: videoItem.enabled = (videoItem.player.playing && !videoItem.player.paused)
        onPausedChanged: videoItem.enabled = (videoItem.player.playing && !videoItem.player.paused)
    }

    // Poster
    Thumbnail {
        id: poster

        anchors.centerIn: parent

        width: videoItem.width
        height: videoItem.height

        sourceSize.width: screen.height
        sourceSize.height: screen.height

        source: videoItem.source
        mimeType: videoItem.mimeType

        priority: Thumbnail.HighPriority
        fillMode: Thumbnail.PreserveAspectFit
        visible: !videoItem.active || !videoItem.player.visible
    }

    Item {
        width: videoItem.width
        height: videoItem.height

        opacity: videoItem.enabled ? 0.0 : 1.0
        Behavior on opacity { NumberAnimation {} }

        Image {
            anchors.centerIn: parent
            source: "image://theme/icon-cover-play"

            MouseArea {
                anchors.fill: parent
                enabled: !videoItem.enabled
                onClicked: {
                    videoItem.player.visible = true
                    videoItem.player.source = videoItem.source
                    videoItem.player.play()
                }
            }
        }

        Slider {
            id: positionSlider

            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }

            height: theme.itemSizeSmall
            handleVisible: false
            minimumValue: 0
//            valueText: Locale.formatDuration(value)

            onReleased: videoItem.player.position = value * 1000
        }
    }
}
