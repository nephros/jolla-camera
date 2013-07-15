import QtQuick 2.0
import Sailfish.Silica 1.0

ComboBox {
    property QtObject settings
    property string property

    property bool _updatingIndex

    function updateCurrentIndex() {
        for (var i = 0; i < menu.children.length; ++i) {
            var item = menu.children[i]
            if (item.value !== undefined && item.value == value) {
                _updatingIndex = true
                currentIndex = i
                _updatingIndex = false
                return;
            }
        }
        currentIndex = -1
    }

    Component.onCompleted: updateCurrentIndex()

    property variant value: settings[property]
    onValueChanged: updateCurrentIndex()

    onCurrentItemChanged: {
        if (currentItem && !_updatingIndex) {
            settings[property] = currentItem.value
        }
    }
}
