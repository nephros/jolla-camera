import QtQuick 2.0
import Sailfish.Silica 1.0

Image {
    property url icon

    width: 48
    height: 48

    fillMode: Image.PreserveAspectFit
    source: icon + "?" + Theme.highlightColor
}
