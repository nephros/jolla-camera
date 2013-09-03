
#include "declarativecameraextensions.h"

#include <QMediaService>
#include <QQmlInfo>

#include <QtDebug>
#include <QMediaMetaData>

DeclarativeCameraExtensions::DeclarativeCameraExtensions(QObject *parent)
    : QObject(parent)
    , m_camera(0)
    , m_mediaObject(0)
    , m_deviceControl(0)
    , m_imageEncoderControl(0)
    , m_videoEncoderControl(0)
    , m_metaDataControl(0)
    , m_rotation(-1)
{
}

DeclarativeCameraExtensions::~DeclarativeCameraExtensions()
{
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
}

QObject *DeclarativeCameraExtensions::camera() const
{
    return m_camera;
}

void DeclarativeCameraExtensions::setCamera(QObject *camera)
{
    qDebug() << Q_FUNC_INFO;
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

DeclarativeCameraExtensions::Face DeclarativeCameraExtensions::face() const
{
    return m_face;
}

void DeclarativeCameraExtensions::setFace(Face face)
{
    if (face != m_face) {
        m_face = face;

        setRotation(m_rotation);
        if (m_deviceControl) {
            updateDevice();
        }
        emit faceChanged();
    }
}

int DeclarativeCameraExtensions::rotation() const
{
    return m_rotation;
}

void DeclarativeCameraExtensions::setRotation(int rotation)
{
    if (m_imageEncoderControl) {
        QImageEncoderSettings imageSettings = m_imageEncoderControl->imageSettings();
        imageSettings.setEncodingOption(QLatin1String("rotation"), rotation);
        m_imageEncoderControl->setImageSettings(imageSettings);
    }

    if (m_videoEncoderControl) {
        QVideoEncoderSettings videoSettings = m_videoEncoderControl->videoSettings();
        videoSettings.setEncodingOption(QLatin1String("rotation"), rotation);
        m_videoEncoderControl->setVideoSettings(videoSettings);
    }

    if (m_metaDataControl) {
        int orientation = (m_face == Back ? 90 - rotation : 270 + rotation) % 360;
        if (orientation < 0) {
            orientation += 360;
        }
        m_metaDataControl->setMetaData(
                    QMediaMetaData::Orientation,
                    QString(QStringLiteral("rotate-%1")).arg(orientation));
    }

    if (m_rotation != rotation) {
        m_rotation = rotation;
        emit rotationChanged();
    }
}

void DeclarativeCameraExtensions::updateDevice()
{
    QString deviceName;
    if (m_face == Back) {
        deviceName = QLatin1String("primary");
    } else if (m_face == Front) {
        deviceName = QLatin1String("secondary");
    } else {
        deviceName = QString();
    }

    for (int i = 0; i < m_deviceControl->deviceCount(); ++i) {
        if (m_deviceControl->deviceName(i) == deviceName) {
            m_deviceControl->setSelectedDevice(i);
            return;
        }
    }
    qmlInfo(this) << deviceName << "is not a supported device";
}
