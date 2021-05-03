/****************************************************************************************
**
** Copyright (C) 2021 Jolla Ltd.
** All rights reserved.
**
** License: Proprietary
**
****************************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.4
import "pages"

ApplicationWindow {
    id: mainWindow

    background.color: "black"
    cover: Qt.resolvedUrl("cover/CameraTestCover.qml")
    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All

    initialPage: Component {
        Page {
            id: mainPage

            property bool pushAttached: status === PageStatus.Active
            onPushAttachedChanged: {
                pageStack.pushAttached(Qt.resolvedUrl("pages/SettingsPage.qml"), { 'camera': camera })
                pushAttached = false
            }

            VideoOutput {
                id: videoOutput

                z: -1
                width: parent.width
                height: parent.height
                fillMode: VideoOutput.PreserveAspectFit
                source: Camera {
                    id: camera

                    imageCapture.onImageSaved: preview.source = path
                    videoRecorder {
                        frameRate: 30
                        audioChannels: 2
                        audioSampleRate: 48000
                        audioCodec: "audio/mpeg, mpegversion=(int)4"
                        audioEncodingMode: CameraRecorder.AverageBitRateEncoding
                        videoCodec: "video/x-h264"
                        mediaContainer: "video/quicktime, variant=(string)iso"
                        resolution: "1280x720"
                        videoBitRate: 12000000
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (videoOutput.state == "miniature") {
                            pageStack.navigateBack()
                        } else {
                            pageStack.navigateForward()
                        }
                    }
                }

                states: State {
                    name: "miniature"
                    when: mainPage.status === PageStatus.Inactive || mainPage.status === PageStatus.Activating
                    PropertyChanges {
                        target: videoOutput
                        parent: pageStack
                        z: 1000
                        width: Theme.itemSizeExtraLarge
                        height: width
                        x: parent.width - width - Theme.paddingLarge
                        y: parent.height - height - Theme.paddingLarge
                    }
                }
            }

            PageHeader {
                z: 1
                title: "Settings"
                interactive: true
            }

            MouseArea {
                width: Theme.itemSizeExtraLarge
                height: Theme.itemSizeExtraLarge

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: Theme.paddingLarge
                }

                onPressed: camera.searchAndLock()
                onReleased: {
                    if (camera.captureMode === Camera.CaptureVideo) {
                        if (camera.videoRecorder.recorderState == CameraRecorder.RecordingState) {
                            camera.videoRecorder.stop()
                        } else {
                            camera.videoRecorder.record()
                        }
                    } else {
                        if (containsMouse) {
                            camera.imageCapture.capture()
                        } else {
                            camera.unlock()
                        }
                    }
                }
                onCanceled: camera.unlockAutoFocus()

                Rectangle {
                    id: backgroundCircle

                    radius: width / 2
                    width: image.width
                    height: width

                    anchors.centerIn: parent

                    color: Theme.secondaryHighlightColor
                }

                Image {
                    id: image
                    anchors.centerIn: parent
                    source: camera.videoRecorder.recorderState == CameraRecorder.RecordingState
                            ? "image://theme/icon-camera-video-shutter-off"
                            : (camera.captureMode == Camera.CaptureVideo
                               ? "image://theme/icon-camera-video-shutter-on"
                               : "image://theme/icon-camera-shutter")
                }
            }

            MouseArea {

                onClicked: Qt.openUrlExternally(preview.source)

                anchors {
                    left: parent.left
                    bottom: parent.bottom
                    margins: Theme.paddingLarge
                }

                width: Theme.itemSizeExtraLarge
                height: Theme.itemSizeExtraLarge
                opacity: containsMouse && pressed ? 0.6 : 1.0

                Image {
                    id: preview
                    z: -1
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                }
            }
        }
    }
}
