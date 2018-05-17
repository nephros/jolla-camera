import QtQuick 2.0
import Sailfish.Silica 1.0

ComboBox {
    property QtObject settings

    property bool _updatingIndex

    function updateCurrentIndex() {
        for (var i = 0; i < menu.children.length; ++i) {
            var item = menu.children[i]
            if (item.videoResolution !== undefined && item.videoResolution == resolution) {
                _updatingIndex = true
                currentIndex = i
                _updatingIndex = false
                return;
            }
        }
        currentIndex = -1
    }

    Component.onCompleted: updateCurrentIndex()

    property var resolution: settings.videoResolution
    onResolutionChanged: updateCurrentIndex()

    onCurrentItemChanged: {
        if (currentItem) {
            settings.viewfinderResolution = currentItem.viewfinderResolution
            settings.videoResolution = currentItem.videoResolution
        }
    }
}
