import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera.settings 1.0

ComboBox {
    property string property

    property variant value: Settings[property]
    onValueChanged: {
        for (var i = 0; i < menu.children.length; ++i) {
            var item = menu.children[i]
            if (item.value !== undefined && item.value == value) {
                currentIndex = i
                return;
            }
        }
        currentIndex = -1
    }

    onCurrentItemChanged: {
        if (currentItem) {
            Settings[property] = currentItem.value
        }
    }
}
