#include "declarativeexposure.h"

DeclarativeExposure::DeclarativeExposure(QCamera *camera, QObject *parent)
    : QObject(parent)
    , m_camera(camera)
    , m_control(0)
    , m_autoIso(true)
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


int DeclarativeExposure::iso() const
{
    return m_control
            ? m_control->exposureParameter(QCameraExposureControl::ISO).toInt()
            : 0;
}

void DeclarativeExposure::setIso(int iso)
{
    if (m_control) {
        bool autoIso = m_autoIso;
        m_autoIso = true;
        m_control->setExposureParameter(QCameraExposureControl::ISO, iso);
        if (!autoIso) {
            emit automaticIsoChanged();
        }
    }
}

void DeclarativeExposure::resetIso()
{
    if (m_control && !m_autoIso) {
        m_autoIso = false;
        m_control->setExposureParameter(QCameraExposureControl::ISO, QVariant());
        emit automaticIsoChanged();
    }
}

bool DeclarativeExposure::hasAutomaticIso() const
{
    return m_autoIso;
}

QVariantList DeclarativeExposure::supportedIso() const
{
    return m_control
            ? m_control->supportedParameterRange(QCameraExposureControl::ISO)
            : QVariantList();
}

void DeclarativeExposure::parameterChanged(int parameter)
{
    if (parameter == QCameraExposureControl::ExposureCompensation) {
        emit compensationChanged();
    } else if (parameter == QCameraExposureControl::ISO) {
        emit isoChanged();
    }
}

void DeclarativeExposure::parameterRangeChanged(int parameter)
{
    if (parameter == QCameraExposureControl::ISO) {
        emit supportedIsoChanged();
    }
}
