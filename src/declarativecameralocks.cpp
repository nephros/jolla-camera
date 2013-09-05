
#include "declarativecameralocks.h"

DeclarativeCameraLocks::DeclarativeCameraLocks(QObject *parent)
    : QObject(parent)
    , m_camera(0)
    , m_mediaObject(0)
    , m_locksControl(0)
{
}

DeclarativeCameraLocks::~DeclarativeCameraLocks()
{
    if (m_mediaObject && m_locksControl) {
        m_mediaObject->service()->releaseControl(m_locksControl);
    }
}

QObject *DeclarativeCameraLocks::camera() const
{
    return m_camera;
}

void DeclarativeCameraLocks::setCamera(QObject *camera)
{
    if (m_locksControl) {
        disconnect(m_locksControl, SIGNAL(lockStatusChanged(QCamera::LockType,QCamera::LockStatus,QCamera::LockChangeReason)),
                this, SLOT(lockStatusChanged(QCamera::LockType)));
        m_mediaObject->service()->releaseControl(m_locksControl);
        m_locksControl = 0;
    }

    m_camera = camera;
    m_mediaObject = m_camera
            ? qobject_cast<QMediaObject *>(m_camera->property("mediaObject").value<QObject *>())
            : 0;

    if (m_mediaObject
            && m_mediaObject->service()
            && (m_locksControl = m_mediaObject->service()->requestControl<QCameraLocksControl *>())) {
        connect(m_locksControl, SIGNAL(lockStatusChanged(QCamera::LockType,QCamera::LockStatus,QCamera::LockChangeReason)),
                this, SLOT(lockStatusChanged(QCamera::LockType)));
    }
}

DeclarativeCameraLocks::Status DeclarativeCameraLocks::focusStatus() const
{
    return m_locksControl
            ? DeclarativeCameraLocks::Status(m_locksControl->lockStatus(QCamera::LockFocus))
            : DeclarativeCameraLocks::Unlocked;
}

DeclarativeCameraLocks::Status DeclarativeCameraLocks::exposureStatus() const
{
    return m_locksControl
            ? DeclarativeCameraLocks::Status(m_locksControl->lockStatus(QCamera::LockExposure))
            : DeclarativeCameraLocks::Unlocked;
}

DeclarativeCameraLocks::Status DeclarativeCameraLocks::whiteBalanceStatus() const
{
    return m_locksControl
            ? DeclarativeCameraLocks::Status(m_locksControl->lockStatus(QCamera::LockWhiteBalance))
            : DeclarativeCameraLocks::Unlocked;
}

void DeclarativeCameraLocks::lockFocus()
{
    if (m_locksControl) {
        m_locksControl->searchAndLock(QCamera::LockFocus);
    }
}

void DeclarativeCameraLocks::unlockFocus()
{
    if (m_locksControl) {
        m_locksControl->unlock(QCamera::LockFocus);
    }
}

void DeclarativeCameraLocks::lockExposure()
{
    if (m_locksControl) {
        m_locksControl->unlock(QCamera::LockExposure);
    }
}

void DeclarativeCameraLocks::unlockExposure()
{
    if (m_locksControl) {
        m_locksControl->unlock(QCamera::LockExposure);
    }
}

void DeclarativeCameraLocks::lockWhiteBalance()
{
    if (m_locksControl) {
        m_locksControl->unlock(QCamera::LockWhiteBalance);
    }
}

void DeclarativeCameraLocks::unlockWhiteBalance()
{
    if (m_locksControl) {
        m_locksControl->unlock(QCamera::LockWhiteBalance);
    }
}

void DeclarativeCameraLocks::lockStatusChanged(QCamera::LockType type)
{
    switch (type) {
    case  QCamera::LockExposure:
        emit exposureStatusChanged();
        break;
    case QCamera::LockWhiteBalance:
        emit whiteBalanceStatusChanged();
        break;
    case QCamera::LockFocus:
        emit focusStatusChanged();
        break;
    default:
        break;
    }
}
