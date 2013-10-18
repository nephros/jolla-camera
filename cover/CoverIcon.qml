import QtQuick 2.0
import Sailfish.Silica 1.0

Image {
    property url icon

    width: Theme.iconSizeSmall + Theme.paddingMedium
    height: Theme.iconSizeSmall + Theme.paddingMedium
    fillMode: Image.PreserveAspectFit
    source: icon + "?" + Theme.highlightDimmerColor
}
