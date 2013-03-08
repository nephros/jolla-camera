import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

PopupPanel {
    property Camera camera

    width: row.width
    height: theme.paddingLarge + theme.itemSizeExtraLarge
    alignment: PanelAlignment.Top

    Row {
        id: row

        anchors.bottom: parent.bottom

        IconButton {
        }

        IconButton {
        }

        IconButton {

        }
    }
}
