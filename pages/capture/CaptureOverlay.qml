import QtQuick 2.0
import QtMultimedia 5.4
import QtPositioning 5.1
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import com.jolla.camera 1.0
import org.nemomobile.time 1.0
import org.nemomobile.policy 1.0
import org.nemomobile.ngf 1.0
import org.nemomobile.configuration 1.0
import org.nemomobile.notifications 1.0
import QtSystemInfo 5.0
import QtPositioning 5.1

import "../settings"

SettingsOverlay {
    id: settingsOverlay

    property var captureView
    property var camera
    property Item focusArea
    property alias captureButtonPressed: captureButton.pressed

    property int _recordingDuration: clock.enabled ? ((clock.time - _startTime) / 1000) : 0
    property var _startTime: new Date()

    width: captureView.width
    height: captureView.height

    function writeMetaData() {
        captureView.captureOrientation = captureView.viewfinderOrientation
        // Camera documentation says dateTimeOriginal should be used but at the moment CameraBinMetaData uses only
        // date property (which the documentation doesn't even list)
        camera.metaData.date = new Date()

        if (positionSource.active) {
            var coordinate = positionSource.position.coordinate
            if (coordinate.isValid) {
                camera.metaData.gpsLatitude = coordinate.latitude
                camera.metaData.gpsLongitude = coordinate.longitude
            } else {
                camera.metaData.gpsLatitude = undefined
                camera.metaData.gpsLongitude = undefined
            }
            camera.metaData.gpsAltitude = positionSource.position.altitudeValid
                        ? coordinate.altitude
                        : undefined
        } else {
            camera.metaData.gpsLatitude = undefined
            camera.metaData.gpsLongitude = undefined
            camera.metaData.gpsAltitude = undefined
        }
    }

    readonly property int storagePathStatus: Settings.storagePathStatus
    onStoragePathStatusChanged: checkStorage()

    readonly property bool _applicationActive: Qt.application.state == Qt.ApplicationActive
    on_ApplicationActiveChanged: if (_applicationActive) checkStorage()

    Component.onCompleted: checkStorage()

    function checkStorage() {
        if (Qt.application.state != Qt.ApplicationActive) {
            // We don't want to show notification when we're in the background
            return
        }

        var prevStatus = previousStoragePathStatus.value
        if (Settings.storagePathStatus == Settings.Unavailable) {
            if (prevStatus != Settings.storagePathStatus) {
                notification.close()
                //% "The selected storage is unavailable. Device memory will be used instead"
                notification.publishMessage(qsTrId("camera-me-storage-unavailable"))
            }
        } else if (Settings.storagePathStatus == Settings.Available) {
            if (prevStatus == Settings.Unavailable || prevStatus == Settings.Mounting) {
                notification.close()
                //% "Using memory card"
                notification.publishMessage(qsTrId("camera-me-using-memory-card"))
            }
        } else if (Settings.storagePathStatus == Settings.Mounting) {
            notification.close()
            //% "Busy mounting the memory card. Device memory will be used instead"
            notification.publishMessage(qsTrId("camera-me-storage-mounting"))
        }
        previousStoragePathStatus.value = Settings.storagePathStatus
    }

    PositionSource {
        id: positionSource
        active: captureView.effectiveActive && Settings.locationEnabled && Settings.global.saveLocationInfo
    }

    opacity: 0.0

    isPortrait: captureView.isPortrait
    topButtonRowHeight: Screen.sizeCategory >= Screen.Large ? Theme.itemSizeLarge : Theme.itemSizeSmall

    onPinchStarted: {
        // We're not getting notifications when the maximumDigitalZoom changes,
        // so update the value here.
        zoomIndicator.maximumZoom = camera.maximumDigitalZoom
    }

    onPinchUpdated: {
        camera.digitalZoom = Math.max(1, Math.min(
                    camera.digitalZoom + ((camera.maximumDigitalZoom - 1) * ((pinch.scale / Math.abs(pinch.previousScale) - 1))),
                    camera.maximumDigitalZoom))
        zoomIndicator.show()
    }

    Connections {
        target: captureView
        ignoreUnknownSignals: true
        onEffectiveActiveChanged: {
            if (!captureView.effectiveActive) {
                settingsOverlay.open = false
                settingsOverlay.inButtonLayout = false
            }
        }
    }

    onClicked: {
        if (!captureView._captureOnFocus
                && Settings.mode.focusDistance != Camera.FocusInfinity) {
            captureView._touchFocus = true

            if (Settings.mode.focusDistance == Camera.FocusAuto) {
                // Translate and rotate the touch point into focusArea's space.
                var focusPoint
                switch ((360 - captureView.viewfinderOrientation) % 360) {

                case 90:
                    focusPoint = Qt.point(
                                mouse.y - ((height - focusArea.width) / 2),
                                width - mouse.x);
                    break;
                case 180:
                    focusPoint = Qt.point(
                                width - mouse.x - ((width - focusArea.width) / 2),
                                height - mouse.y);
                    break;
                case 270:
                    focusPoint = Qt.point(
                                height - mouse.y - ((height - focusArea.width) / 2),
                                mouse.x);
                    break;
                default:
                    focusPoint = Qt.point(
                                mouse.x - ((width - focusArea.width) / 2),
                                mouse.y);
                    break;
                }

                // Normalize the focus point.
                focusPoint.x = focusPoint.x / focusArea.width
                focusPoint.y = focusPoint.y / focusArea.height

                // Mirror the point if the viewfinder is mirrored.
                if (captureView._mirrorViewfinder) {
                    focusPoint.x = 1 - focusPoint.x
                }

                camera.focus.customFocusPoint = focusPoint
            }

            camera.searchAndLock()
        }
    }

    shutter: CameraButton {
        id: captureButton

        z: settingsOverlay.inButtonLayout ? 1 : 0

        enabled: captureView._canCapture
                    && !captureView._captureOnFocus
                    && !volumeDown.pressed
                    && !volumeUp.pressed

        onPressed: camera.autoFocus()
        onClicked: captureView._triggerCapture()

        icon {
            opacity: {
                if (captureTimer.running) {
                    return 0.1
                } else if (captureButton.pressed) {
                    return 0.5
                } else {
                    return 1.0
                }
            }

            source: startRecordTimer.running || camera.videoRecorder.recorderState == CameraRecorder.RecordingState
                    ? "image://theme/icon-camera-stop?" + Theme.highlightColor
                    : "image://theme/icon-camera-shutter-release?" + (captureView._canCapture
                            ? Theme.highlightColor
                            : Theme.highlightDimmerColor)
        }

        Label {
            anchors.centerIn: parent
            text: Math.floor(captureView._captureCountdown + 1)
            visible: captureTimer.running
            opacity: captureView._captureCountdown % 1
            color: Theme.primaryColor
            font {
                pixelSize: Theme.fontSizeHuge
                weight: Font.Light
            }
        }
    }

    timer: Item {
        anchors {
            centerIn: parent
            horizontalCenterOffset: settingsOverlay.timerAlignment == Qt.AlignLeft
                    ? -(timerLabel.width + Theme.paddingMedium - Theme.itemSizeMedium) / 2
                    : (timerLabel.width + Theme.paddingMedium - Theme.itemSizeMedium) / 2
        }
        width: timerLabel.implicitWidth + (2 * Theme.paddingMedium)
        height: timerLabel.implicitHeight + (2 * Theme.paddingSmall)
        opacity: camera.captureMode == Camera.CaptureVideo ? 1 : 0
        Behavior on opacity { FadeAnimation {} }

        Rectangle {
            radius: Theme.paddingSmall / 2

            anchors.fill: parent
            color: Theme.highlightBackgroundColor
            opacity: 0.6
        }
        Label {
            id: timerLabel

            anchors.centerIn: parent

            text: Format.formatDuration(_recordingDuration,
                                        _recordingDuration >= 3600 ? Formatter.DurationLong : Formatter.DurationShort)
            font.pixelSize: Theme.fontSizeMedium

        }
    }

    WallClock {
        id: clock
        updateFrequency: WallClock.Second
        enabled: camera.videoRecorder.recorderState == CameraRecorder.RecordingState
        onEnabledChanged: {
            if (enabled) {
                _startTime = clock.time
            }
        }
    }

    // Viewfinder Grid
    Item {
        id: grid

        property real gridWidth: captureView.viewfinderOrientation % 180 == 0 ? focusArea.width : focusArea.height
        property real gridHeight: captureView.viewfinderOrientation % 180 == 0 ? focusArea.height : focusArea.width
        property real ambienceScale: Math.min(Screen.width, Screen.height) /
                                     Math.max(Screen.width, Screen.height)

        anchors.centerIn: parent

        visible: Settings.mode.viewfinderGrid != "none"
                 && camera.cameraStatus == Camera.ActiveStatus

        width: Settings.mode.viewfinderGrid == "ambience"
               ? gridWidth * ambienceScale
               : gridWidth / 3
        height: Settings.mode.viewfinderGrid == "ambience"
                ? gridHeight * ambienceScale
                : gridHeight / 3

        GridLine {
            anchors {
                horizontalCenter: grid.horizontalCenter
                verticalCenter: grid.top
            }
            width: grid.gridWidth
        }

        GridLine {
            anchors {
                horizontalCenter: grid.horizontalCenter
                verticalCenter: grid.bottom
            }
            width: grid.gridWidth
        }

        GridLine {
            anchors {
                horizontalCenter: grid.left
                verticalCenter: grid.verticalCenter
            }
            width: grid.gridHeight
            rotation: 90
        }

        GridLine {
            anchors {
                horizontalCenter: grid.right
                verticalCenter: grid.verticalCenter
            }
            width: grid.gridHeight
            rotation: 90
        }
    }

    ZoomIndicator {
        id: zoomIndicator
        anchors {
            top: parent.top
            topMargin: settingsOverlay.topButtonRowHeight + Theme.paddingLarge
            horizontalCenter: parent.horizontalCenter
        }

        zoom: camera.digitalZoom
        maximumZoom: camera.maximumDigitalZoom
    }

    Rectangle {
        width: 24
        height: 24

        radius: 2
        anchors.centerIn: parent
        color: Theme.primaryColor

        visible: camera.captureMode == Camera.CaptureStillImage
        opacity: Settings.mode.meteringMode == Camera.MeteringSpot ? 1 : 0
        Behavior on opacity { FadeAnimation {} }
    }

    Notification {
        id: notification

        function publishMessage(msg) {
            notification.previewBody = msg
            notification.publish()
        }

        category: "x-jolla.settings.camera"
    }

    ConfigurationValue {
        id: previousStoragePathStatus
        key: "/apps/jolla-camera/previousStoragePathStatus"
    }
}
