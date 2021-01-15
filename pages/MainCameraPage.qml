import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import org.nemomobile.dbus 2.0

CameraPage {
    id: page
    galleryView: Qt.resolvedUrl("gallery/MainGalleryView.qml")

    function dummyTranslations() {
        //% "Enable QR-code recognition"
        qsTrId("camera_settings-la-enable_qr")
        //% "Detect QR-code via camera."
        qsTrId("camera_settings-la-detect_qr_description")
        //% "QR-code"
        qsTrId("jolla-camera-la-qr_code_header")
        //% "Copy"
        qsTrId("jolla-camera-la-qr_code_copy")
    }

    Binding {
        target: window
        property: "galleryActive"
        value: page.galleryActive
    }

    Binding {
        target: window
        property: "galleryVisible"
        value: page.galleryVisible
    }

    Binding {
        target: window
        property: "galleryIndex"
        value: page.galleryIndex
    }

    Binding {
        target: window
        property: "captureModel"
        value: page.captureModel
    }

    Timer {
        running: Qt.application.state != Qt.ApplicationActive && !captureModeActive
        interval: 15*60*1000
        onTriggered: returnToCaptureMode()
    }

    DBusAdaptor {
        iface: "com.jolla.camera.ui"
        service: "com.jolla.camera"
        path: "/"

        signal showViewfinder(variant args)
        onShowViewfinder: {
            page.returnToCaptureMode()
            window.activate()
        }

        signal showFrontViewfinder(bool switchToImageMode)
        onShowFrontViewfinder: {
            if (switchToImageMode) {
                Settings.global.captureMode = "image"
            }
            Settings.cameraDevice = "secondary"
            page.returnToCaptureMode()
            window.activate()
        }
    }
}
