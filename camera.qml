import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "cover"

ApplicationWindow {
    id: window
    cover: Component{
        CameraCover {
        }
    }

    initialPage: Component {
        CameraPage {
            pageStack: window.pageStack
            windowActive: window.applicationActive
        }
    }
}
