import QtQuick 2.6
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

ListView {
    id: root

    property int itemWidth: {
        var maxWidth = 0
        for (var i = 0; i < model.length; i++) {
            var width = fontMetrics.boundingRect( Settings.colorFilterText(model[i])).width
            if (width > maxWidth) {
                maxWidth = width
            }
        }
        return maxWidth + 2*Theme.paddingLarge

    }

    currentIndex: 0
    height: Theme.itemSizeLarge
    orientation: ListView.Horizontal
    flickDeceleration: 2*Theme.flickDeceleration
    maximumFlickVelocity: Theme.maximumFlickVelocity/2

    highlightMoveDuration: 200
    highlightRangeMode: PathView.StrictlyEnforceRange
    preferredHighlightBegin: width/2  - itemWidth/2
    preferredHighlightEnd: width/2 - itemWidth/2
    boundsBehavior: Flickable.StopAtBounds

    header: Item {
        height: 1
        width: (root.width - root.itemWidth)/2
    }

    footer: Item {
        height: 1
        width: (root.width - root.itemWidth)/2
    }

    delegate: MouseArea {
        property bool highlighted: (pressed && containsMouse) || ListView.isCurrentItem
        onClicked: root.currentIndex = model.index

        height: root.height
        width: root.itemWidth

        Label {
            id: label
            text: Settings.colorFilterText(modelData)
            anchors.centerIn: parent
            truncationMode: TruncationMode.Fade
            highlighted: parent.highlighted
        }
    }

    FontMetrics {
        id: fontMetrics
        font.pixelSize: Theme.fontSizeMedium
    }
}
