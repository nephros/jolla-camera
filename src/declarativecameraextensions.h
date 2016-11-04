/*
 * SPDX-FileCopyrightText: 2013 - 2014 Jolla Ltd.
 * SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#ifndef DECLARATIVECAMERAEXTENSIONS_H
#define DECLARATIVECAMERAEXTENSIONS_H

#include <QQuickItem>

class QCameraFastCaptureControl;

class DeclarativeCameraExtensions : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QObject *camera READ camera WRITE setCamera NOTIFY cameraChanged)
    Q_PROPERTY(bool fastCapture READ fastCapture WRITE setFastCapture NOTIFY fastCaptureChanged)

public:
    DeclarativeCameraExtensions(QObject *parent = 0);
    ~DeclarativeCameraExtensions();

    Q_INVOKABLE void disableNotifications(QQuickItem *item, bool disable);

    QObject *camera() const;
    void setCamera(QObject *camera);

    bool fastCapture() const;
    void setFastCapture(bool enabled);

signals:
    void cameraChanged();
    void fastCaptureChanged();

private:
    bool m_fastCapture;
    QObject *m_camera;
    QCameraFastCaptureControl *m_fastCaptureControl;
};

#endif
