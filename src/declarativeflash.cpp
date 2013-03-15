#include "declarativeflash.h"

DeclarativeFlash::DeclarativeFlash(QCamera *camera, QObject *parent)
    : QObject(parent)
    , m_camera(camera)
    , m_control(0)
{
    if ((m_control = m_camera->service()->requestControl<QCameraFlashControl *>())) {
        connect(m_control, SIGNAL(flashReady(bool)), this, SIGNAL(readyChanged()));
    }
}

DeclarativeFlash::~DeclarativeFlash()
{
    if (m_control) {
        m_camera->service()->releaseControl(m_control);
    }
}

DeclarativeFlash::Mode DeclarativeFlash::mode() const
{
    return m_control ? Mode(int(m_control->flashMode())) : Off;
}

void DeclarativeFlash::setMode(Mode mode)
{
    if (m_control && m_control->flashMode() != QCameraExposure::FlashModes(mode)) {
        m_control->setFlashMode(QCameraExposure::FlashModes(mode));
        emit modeChanged();
    }
}

bool DeclarativeFlash::isReady() const
{
    return m_control ? m_control->isFlashReady() : false;
}
