// SPDX-FileCopyrightText: 2013 - 2014 Jolla Ltd.
// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

#include "declarativecameraextensions.h"

#include <QGuiApplication>
#include <QQmlInfo>

#include <QtDebug>

#include <QQuickWindow>
#include <qpa/qplatformnativeinterface.h>

#include <QMediaObject>
#include <QCameraFastCaptureControl>

DeclarativeCameraExtensions::DeclarativeCameraExtensions(QObject *parent)
    : QObject(parent)
    , m_fastCapture(false)
    , m_camera(0)
    , m_fastCaptureControl(0)
{

}

DeclarativeCameraExtensions::~DeclarativeCameraExtensions()
{
}

QObject *DeclarativeCameraExtensions::camera() const
{
    return m_camera;
}

void DeclarativeCameraExtensions::setCamera(QObject *camera)
{
    if (m_camera == camera)
        return;

    m_camera = camera;
    m_fastCaptureControl = 0;

    if (m_camera) {
        QMediaObject *mediaObject = qobject_cast<QMediaObject*>(qvariant_cast<QObject*>(m_camera->property("mediaObject")));
        if (mediaObject) {
            m_fastCaptureControl = qobject_cast<QCameraFastCaptureControl *>(
                        mediaObject->service()->requestControl("com.jollamobile.sailfishos.camerafastcapturecontrol/5.4"));
            if (m_fastCaptureControl) {
                qDebug() << "SET FAST CAPTURE" << m_fastCapture;
                m_fastCaptureControl->setFastCaptureEnabled(m_fastCapture);
            }
        }
    }

    emit cameraChanged();
}

bool DeclarativeCameraExtensions::fastCapture() const
{
    return m_fastCapture;
}

void DeclarativeCameraExtensions::setFastCapture(bool enabled)
{
    if (enabled == m_fastCapture)
        return;

    m_fastCapture = enabled;

    if (m_fastCaptureControl) {
        qDebug() << "SET FAST CAPTURE" << m_fastCapture;
        m_fastCaptureControl->setFastCaptureEnabled(enabled);
    }

    emit fastCaptureChanged();
}

void DeclarativeCameraExtensions::disableNotifications(QQuickItem *item, bool disable)
{
    if (QWindow *window = item ? item->window() : 0) {
        QGuiApplication::platformNativeInterface()->setWindowProperty(
                    window->handle(), QLatin1String("NOTIFICATION_PREVIEWS_DISABLED"),
                    QVariant(disable ? 3 : 0));
    }
}
