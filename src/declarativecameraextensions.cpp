
#include "declarativecameraextensions.h"

#include <QGuiApplication>
#include <QMediaService>
#include <QQmlInfo>

#include <QtDebug>

#include <QQuickWindow>
#include <qpa/qplatformnativeinterface.h>

DeclarativeCameraExtensions::DeclarativeCameraExtensions(QObject *parent)
    : QObject(parent)
    , m_camera(0)
    , m_mediaObject(0)
    , m_deviceControl(0)
    , m_imageEncoderControl(0)
    , m_videoEncoderControl(0)
    , m_metaDataControl(0)
    , m_sensorControl(0)
    , m_rotation(-1)
    , m_orientation(0)
{
}

DeclarativeCameraExtensions::~DeclarativeCameraExtensions()
{
    if (m_mediaObject) {
        if (m_deviceControl) {
            m_mediaObject->service()->releaseControl(m_deviceControl);
        }
        if (m_imageEncoderControl) {
            m_mediaObject->service()->releaseControl(m_imageEncoderControl);
        }
        if (m_videoEncoderControl) {
            m_mediaObject->service()->releaseControl(m_videoEncoderControl);
        }
        if (m_metaDataControl) {
            m_mediaObject->service()->releaseControl(m_metaDataControl);
        }
        if (m_viewfinderSettingsControl) {
            m_mediaObject->service()->releaseControl(m_viewfinderSettingsControl);
        }
        if (m_sensorControl) {
            m_mediaObject->service()->releaseControl(m_sensorControl);
        }
    }
}

QObject *DeclarativeCameraExtensions::camera() const
{
    return m_camera;
}

void DeclarativeCameraExtensions::setCamera(QObject *camera)
{
    if (m_deviceControl) {
        disconnect(m_deviceControl, SIGNAL(lockStatusChanged(QCamera::LockType,QCamera::LockStatus,QCamera::LockChangeReason)),
                this, SLOT(lockStatusChanged(QCamera::LockType)));
        m_mediaObject->service()->releaseControl(m_deviceControl);
        m_deviceControl = 0;
    }
    if (m_imageEncoderControl) {
        m_mediaObject->service()->releaseControl(m_imageEncoderControl);
        m_imageEncoderControl = 0;
    }
    if (m_videoEncoderControl) {
        m_mediaObject->service()->releaseControl(m_videoEncoderControl);
        m_videoEncoderControl = 0;
    }
    if (m_metaDataControl) {
        m_mediaObject->service()->releaseControl(m_metaDataControl);
        m_metaDataControl = 0;
    }
    if (m_viewfinderSettingsControl) {
        m_mediaObject->service()->releaseControl(m_viewfinderSettingsControl);
        m_viewfinderSettingsControl = 0;
    }
    if (m_sensorControl) {
        m_sensorControl->disconnect(this);
        m_mediaObject->service()->releaseControl(m_sensorControl);
        m_sensorControl = 0;
    }

    m_camera = camera;
    m_mediaObject = m_camera
            ? qobject_cast<QMediaObject *>(m_camera->property("mediaObject").value<QObject *>())
            : 0;

    if (m_mediaObject && m_mediaObject->service()) {
        if ((m_deviceControl = m_mediaObject->service()->requestControl<QVideoDeviceSelectorControl *>())) {
            updateDevice();
        }
        m_imageEncoderControl = m_mediaObject->service()->requestControl<QImageEncoderControl *>();
        m_videoEncoderControl = m_mediaObject->service()->requestControl<QVideoEncoderSettingsControl *>();
        m_metaDataControl = m_mediaObject->service()->requestControl<QMetaDataWriterControl *>();
        m_viewfinderSettingsControl = m_mediaObject->service()->requestControl<QCameraViewfinderSettingsControl *>();
        m_sensorControl = m_mediaObject->service()->requestControl<QCameraSensorControl *>();

        if (m_sensorControl) {
            connect(m_sensorControl, &QCameraSensorControl::propertyChanged,
                    this, &DeclarativeCameraExtensions::sensorPropertyChanged);
        }

        if (m_rotation != -1) {
            setRotation(m_rotation);
        }

        if (m_videoEncoderControl) {
            QVideoEncoderSettings settings = m_videoEncoderControl->videoSettings();
            settings.setEncodingOption(QLatin1String("preset"), QLatin1String("high"));
            m_videoEncoderControl->setVideoSettings(settings);
        }
    }
}

QString DeclarativeCameraExtensions::device() const
{
    return m_device;
}

void DeclarativeCameraExtensions::setDevice(const QString &device)
{
    if (device != m_device) {
        m_device = device;

        setRotation(m_rotation);
        if (m_deviceControl) {
            updateDevice();
        }
        emit deviceChanged();
    }
}

int DeclarativeCameraExtensions::rotation() const
{
    return m_rotation;
}

QDateTime DeclarativeCameraExtensions::captureTime() const
{
    return m_captureTime;
}

void DeclarativeCameraExtensions::setCaptureTime(const QDateTime &time)
{
    if (m_captureTime != time) {
        m_captureTime = time;

        if (m_metaDataControl) {
            m_metaDataControl->setMetaData(QMediaMetaData::Date, m_captureTime);
        }

        emit captureTimeChanged();
    }
}

void DeclarativeCameraExtensions::setRotation(int rotation)
{
    int sensorOrientation = m_sensorControl
            ? m_sensorControl->property(QCameraSensorControl::Orientation).toInt()
            : 0;

    const int correctedRotation = m_device == QLatin1String("secondary")
            ? -rotation
            : rotation;

    int orientation = (sensorOrientation - correctedRotation) % 360;
    if (orientation < 0) {
        orientation += 360;
    }

    if (m_imageEncoderControl) {
        QImageEncoderSettings imageSettings = m_imageEncoderControl->imageSettings();
        imageSettings.setEncodingOption(QLatin1String("rotation"), correctedRotation);
        m_imageEncoderControl->setImageSettings(imageSettings);
    }

    if (m_videoEncoderControl) {
        QVideoEncoderSettings videoSettings = m_videoEncoderControl->videoSettings();
        videoSettings.setEncodingOption(QLatin1String("rotation"), correctedRotation);
        m_videoEncoderControl->setVideoSettings(videoSettings);
    }

    if (m_viewfinderSettingsControl && m_viewfinderResolution.isValid()) {
        m_viewfinderSettingsControl->setViewfinderParameter(
                    QCameraViewfinderSettingsControl::Resolution, m_viewfinderResolution);
    }

    if (m_metaDataControl) {
        m_metaDataControl->setMetaData(
                    QMediaMetaData::Orientation,
                    QString(QStringLiteral("rotate-%1")).arg(orientation));
    }

    if (m_orientation != -orientation) {
        m_orientation = -orientation;
        emit orientationChanged();
    }

    if (m_rotation != rotation) {
        m_rotation = rotation;
        emit rotationChanged();
    }
}

int DeclarativeCameraExtensions::orientation() const
{
    return m_orientation;
}

QSize DeclarativeCameraExtensions::viewfinderResolution() const
{
    return m_viewfinderResolution;
}

void DeclarativeCameraExtensions::setViewfinderResolution(const QSize &resolution)
{
    if (m_viewfinderResolution != resolution) {
        m_viewfinderResolution = resolution;
        if (m_viewfinderSettingsControl) {
            m_viewfinderSettingsControl->setViewfinderParameter(
                        QCameraViewfinderSettingsControl::Resolution, resolution);
        }
        emit viewfinderResolutionChanged();
    }
}

void DeclarativeCameraExtensions::disableNotifications(QQuickItem *item, bool disable)
{
    if (QWindow *window = item ? item->window() : 0) {
        QGuiApplication::platformNativeInterface()->setWindowProperty(
                    window->handle(), QLatin1String("NOTIFICATION_PREVIEWS_DISABLED"),
                    QVariant(disable ? 3 : 0));
    }
}

void DeclarativeCameraExtensions::updateDevice()
{
    for (int i = 0; i < m_deviceControl->deviceCount(); ++i) {
        if (m_deviceControl->deviceName(i) == m_device) {
            m_deviceControl->setSelectedDevice(i);
            return;
        }
    }
}


QVariant DeclarativeCameraExtensions::metaData(const QString &key) const
{
    return m_metaDataControl ? m_metaDataControl->metaData(key) : QVariant();
}

void DeclarativeCameraExtensions::setMetaData(const QString &key, const QVariant &value)
{
    if (m_metaDataControl) {
        m_metaDataControl->setMetaData(key, value);
    }
}

void DeclarativeCameraExtensions::sensorPropertyChanged(QCameraSensorControl::Property)
{
    setRotation(m_rotation);
}
