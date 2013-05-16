
#include "declarativecameraextensions.h"

#include <QMediaService>
#include <QDeclarativeInfo>

#include <QtDebug>

DeclarativeCameraExtensions::DeclarativeCameraExtensions(QObject *parent)
    : QObject(parent)
    , m_camera(0)
    , m_mediaObject(0)
    , m_deviceControl(0)
{
}

DeclarativeCameraExtensions::~DeclarativeCameraExtensions()
{
    if (m_deviceControl) {
        m_mediaObject->service()->releaseControl(m_deviceControl);
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

    m_camera = camera;
    m_mediaObject = m_camera
            ? qobject_cast<QMediaObject *>(m_camera->property("mediaObject").value<QObject *>())
            : 0;

    if (m_mediaObject
            && m_mediaObject->service()
            && (m_deviceControl = m_mediaObject->service()->requestControl<QVideoDeviceControl *>())) {
        updateDevice();
        for (int i = 0; i < m_deviceControl->deviceCount(); ++i) {
            qDebug() << m_deviceControl->deviceName(i) << m_deviceControl->deviceDescription(i);
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
        if (m_deviceControl) {
            updateDevice();
        }
        emit faceChanged();
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
