import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import com.jolla.camera.settings 1.0
import "../settings"
import "../views"

SplitItem {
    id: captureView

    property bool active
    property bool windowActive
    property int effectiveIso: settings.effectiveIso

    property bool menuOpen: captureView.contracted
            || shootingModeOverlay.expanded
            || settingsCompass.expanded
            || captureCompass.expanded

    property bool _complete


    signal openCameraRoll

    dock: Dock.Right

    onEffectiveIsoChanged: {
        if (effectiveIso == 0) {
            camera.exposure.setAutoIsoSensitivity()
        } else {
            camera.exposure.manualIso = settings.effectiveIso
        }
    }

    Component.onCompleted: _complete = true

    Camera {
        id: camera

        property alias locks: cameraLocks

        captureMode: Camera.CaptureStillImage
        cameraState: captureView._complete && captureView.windowActive
                    ? (captureView.active ? Camera.ActiveState : Camera.LoadedState)
                    : Camera.UnloadedState

        imageCapture.resolution: settings.defaultImageResolution(settings.aspectRatio)
        videoRecorder{
            resolution: settings.defaultVideoResolution(settings.aspectRatio)
            frameRate: 15
        }
        focus.focusMode: captureMode == Camera.CaptureStillImage
                    ? settings.effectiveFocusDistance
                    : settings.videoFocus
        flash.flashMode: settings.effectiveFlash
        imageProcessing.whiteBalanceMode: settings.effectiveWhiteBalance

        exposure {
            exposureMode: settings.exposureMode
            exposureCompensation: settings.exposureCompensation / 2.0
            meteringMode: settings.effectiveMeteringMode
        }
    }

    CameraLocks {
        id: cameraLocks
        camera: camera
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            captureView.split = false
            shootingModeOverlay.open = false
            settingsCompass.closeMenu()
            captureCompass.closeMenu()
        }
    }

    VideoOutput {
        x: -parent.x / 2
        width: page.width
        height: page.height

        source: camera
        fillMode: VideoOutput.PreserveAspectFit
    }

    ShootingModeOverlay {
        id: shootingModeOverlay

        camera: camera

        x: -parent.x / 2
        width: page.width
        height: page.height

        enabled: !captureView.contracted
        interactive: !settingsCompass.expanded && !captureCompass.expanded

        SettingsCompass {
            id: settingsCompass

            camera: camera
            enabled: !shootingModeOverlay.expanded

            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                margins: theme.paddingLarge
            }

            onClicked: captureView.split = true
        }

        Rectangle {
            id: focus

            width: theme.itemSizeExtraLarge
            height: width

            anchors.centerIn: parent

            radius: width / 2
            border.width: 3
            border.color: theme.highlightColor
            color: "#00000000"
        }

        CaptureCompass {
            id: captureCompass

            camera: camera

            enabled: !shootingModeOverlay.expanded

            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: theme.paddingLarge
            }
        }

        Item {
            anchors {
                horizontalCenter: captureCompass.horizontalCenter
                top: captureCompass.bottom
                margins: theme.paddingLarge + theme.paddingMedium
            }

            width: durationText.width
            height: durationText.height

            opacity: camera.videoRecorder.recorderState == CameraRecorder.RecordingState
                    ? 1.0
                    : 0.0
            Behavior on opacity { FadeAnimation {} }

            Rectangle {
                radius: height / 2
                color: theme.highlightBackgroundColor
                opacity: 0.3
                anchors {
                    fill: parent
                    margins: -theme.paddingMedium
                }
            }

            Formatter {
                id: formatter
            }

            Label {
                id: durationText

                text: formatter.formatDuration(camera.videoRecorder.duration, Formatter.DurationLong)
                font.pixelSize: theme.fontSizeExtraSmall
            }
        }
    }

    background: [
        Loader {
//            asynchronous: true

            SettingsMenu {
                width: captureView.backgroundItem.width
                height: captureView.backgroundItem.height

                camera: camera
            }
        }

    ]
}
