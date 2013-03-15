#include "declarativeexposure.h"

DeclarativeExposure::DeclarativeExposure(QCamera *camera, QObject *parent)
    : QObject(parent)
    , m_camera(camera)
    , m_control(0)
{
    if ((m_control = m_camera->service()->requestControl<QCameraExposureControl *>())) {
        connect(m_control, SIGNAL(flashReady(bool)), this, SIGNAL(readyChanged()));
    }
}

DeclarativeExposure::~DeclarativeExposure()
{
    if (m_control) {
        m_camera->service()->releaseControl(m_control);
    }
}

qreal DeclarativeExposure::compensation() const
{
    return m_control
            ? m_control->exposureParameter(QCameraExposureControl::ExposureCompensation).toReal()
            : 0;
}

void DeclarativeExposure::setCompensation(qreal compensation)
{
    if (m_control) {
        m_control->setExposureParameter(QCameraExposureControl::ExposureCompensation, compensation);
    }
}

void DeclarativeExposure::parameterChanged(int parameter)
{
    if (parameter == QCameraExposureControl::ExposureCompensation) {
        emit compensationChanged();
    }
}
