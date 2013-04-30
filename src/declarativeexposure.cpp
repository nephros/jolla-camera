#include "declarativeexposure.h"

DeclarativeExposure::DeclarativeExposure(QCamera *camera, QObject *parent)
    : QObject(parent)
    , m_camera(camera)
    , m_control(0)
    , m_autoIso(true)
{
    if (m_camera->service()
            && (m_control = m_camera->service()->requestControl<QCameraExposureControl *>())) {
        connect(m_control, SIGNAL(exposureParameterChanged(int)), this, SLOT(parameterChanged(int)));
        connect(m_control, SIGNAL(exposureParameterRangeChanged(int)), this, SLOT(parameterRangeChanged(int)));
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

DeclarativeCamera::ExposureMode DeclarativeExposure::mode() const
{
    return m_control
            ? DeclarativeCamera::ExposureMode(m_control->exposureMode())
            : DeclarativeCamera::ExposureAuto;
}

void DeclarativeExposure::setMode(DeclarativeCamera::ExposureMode mode)
{
    if (m_control) {
        m_control->setExposureMode(QCameraExposure::ExposureMode(mode));
        emit modeChanged();
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
        m_autoIso = false;
        m_control->setExposureParameter(QCameraExposureControl::ISO, iso);
        if (!autoIso) {
            emit automaticIsoChanged();
        }
    }
}

void DeclarativeExposure::setAutoIsoSensitivity()
{
    if (m_control && !m_autoIso) {
        m_autoIso = true;
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

DeclarativeCamera::MeteringMode DeclarativeExposure::meteringMode() const
{
    return m_control
            ? DeclarativeCamera::MeteringMode(m_control->meteringMode())
            : DeclarativeCamera::MeteringMatrix;
}

void DeclarativeExposure::setMeteringMode(DeclarativeCamera::MeteringMode mode)
{
    if (m_control) {
        m_control->setMeteringMode(QCameraExposure::MeteringMode(mode));
        emit meteringModeChanged();
    }
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
