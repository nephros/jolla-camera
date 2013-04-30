import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera.settings 1.0

ComboBox {
    property string property

    function updateCurrentIndex() {
        for (var i = 0; i < menu.children.length; ++i) {
            var item = menu.children[i]
            if (item.value !== undefined && item.value == value) {
                currentIndex = i
                return;
            }
        }
        currentIndex = -1
    }

    Component.onCompleted: updateCurrentIndex()

    property variant value: settings[property]
    onValueChanged: updateCurrentIndex()

    onCurrentItemChanged: {
        if (currentItem) {
            settings[property] = currentItem.value
        }
    }
}
