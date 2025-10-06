// SPDX-FileCopyrightText: 2016 - 2021 Jolla Ltd.
// SPDX-FileCopyrightText: 2020 - 2021 Open Mobile Platform LLC.
// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.1
import QtQuick.Window 2.1
import Amber.QrFilter 1.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0
import QtMultimedia 5.0

ApplicationWindow {
    id: window

    allowedOrientations: defaultAllowedOrientations
    _defaultPageOrientations: Orientation.All
    _defaultLabelFormat: Text.PlainText
    _backgroundVisible: false

    cover: undefined

    Timer {
        running: window.Window.visibility === Window.Hidden
        interval: 20000
        onTriggered: Qt.quit()
    }

    initialPage: Component {
        CameraPage {
            id: cameraPage
            viewfinder: videoOutput
            galleryView: Qt.resolvedUrl("LockedGalleryView.qml")
        }
    }


    Rectangle {
        parent: window
        anchors.fill: parent

        color: "black"
        z: -2
    }

    VideoOutput {
        id: videoOutput

        z: -1
        parent: window
        width: window.width
        height: window.height

        // filters: [ qrFilter ]
    }

    QrFilter {
        id: qrFilter
        // TODO: trigger result url clicking only after unlocking and enable with such
        active: false
    }
}
