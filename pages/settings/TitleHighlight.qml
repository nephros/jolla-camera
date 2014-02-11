import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    height: Theme.itemSizeMedium

    gradient: Gradient {
        GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightColor, 0.6) }
        GradientStop { position: 1.0; color: Theme.rgba(Theme.highlightColor, 0.0) }
    }
}
