
#include "cameraconfigs.h"
#include <QCamera>
#include <QMediaRecorder>
#include <QCameraImageCapture>

CameraConfigs::CameraConfigs(QObject *parent)
    : QObject(parent)
{
}

CameraConfigs::~CameraConfigs()
{
}

QObject *CameraConfigs::camera() const
{
    return m_camera;
}

void CameraConfigs::setCamera(QObject * camera)
{
    m_qmlCamera = camera;
    QCamera *qCamera = camera->property("mediaObject").value<QCamera *>();

    if (m_camera != qCamera) {
        m_camera = qCamera;

        connect(m_camera, &QCamera::statusChanged, this, &CameraConfigs::handleStatus);
        connect(m_camera, &QCamera::stateChanged , this, &CameraConfigs::handleState);
        m_initialized = false;
        handleStatus();

        emit cameraChanged();
    }
}

void CameraConfigs::handleState()
{
    if (m_camera && m_camera->state() == QCamera::UnloadedState) {
        m_initialized = false;
    }
}

void CameraConfigs::handleStatus()
{
    if (!m_initialized) {
        if (m_camera && (m_camera->status() == QCamera::StartingStatus || m_camera->status() == QCamera::ActiveStatus)) {

            m_supportedViewfinderResolutions.clear();
            for (const QSize resolution : m_camera->supportedViewfinderResolutions()) {
                m_supportedViewfinderResolutions.append(resolution);
            }

            QObject *qmlCapture = qvariant_cast<QObject *>(m_qmlCamera->property("imageCapture"));
            QList<QCameraImageCapture *> captures = qmlCapture->findChildren<QCameraImageCapture *>();
            if (captures.count() > 0) {
                QCameraImageCapture *capture = captures[0];
                m_supportedImageResolutions.clear();
                for (const QSize resolution : capture->supportedResolutions()) {
                    m_supportedImageResolutions.append(resolution);
                }
            }

            QObject *qmlRecorder = qvariant_cast<QObject *>(m_qmlCamera->property("videoRecorder"));
            QList<QMediaRecorder *> recorders = qmlRecorder->findChildren<QMediaRecorder *>();
            if (recorders.count() > 0) {
                QMediaRecorder *recorder = recorders[0];
                m_supportedVideoResolutions.clear();
                for (const QSize resolution : recorder->supportedResolutions()) {
                    m_supportedVideoResolutions.append(resolution);
                }
            }

            m_supportedIsoSensitivities.clear();
            if (m_camera) {
                for (int value : m_camera->exposure()->supportedIsoSensitivities()) {
                    m_supportedIsoSensitivities.append(value);
                }
            }

            m_supportedWhiteBalanceModes.clear();
            if (m_camera) {
                // TODO: Use QMetaEnum::fromType<Class::EnumName>() once Qt Multimedia uses Q_ENUM
                QMetaObject meta = QCameraImageProcessing::staticMetaObject;
                for (int i=0; i < meta.enumeratorCount(); ++i) {
                    QMetaEnum e = meta.enumerator(i);
                    if (e.name() == QLatin1String("WhiteBalanceMode")) {
                        for (int i = 0; i < e.keyCount(); i++) {
                            int mode = e.value(i);
                            if (m_camera->imageProcessing()->isWhiteBalanceModeSupported(static_cast<QCameraImageProcessing::WhiteBalanceMode>(mode))) {
                                m_supportedWhiteBalanceModes.append(mode);
                            }
                        }
                        break;
                    }
                }
            }

            m_supportedExposureModes.clear();
            if (m_camera) {
                // TODO: Use QMetaEnum::fromType<Class::EnumName>() once Qt Multimedia uses Q_ENUM
                QMetaObject meta = QCameraExposure::staticMetaObject;
                for (int i=0; i < meta.enumeratorCount(); ++i) {
                    QMetaEnum e = meta.enumerator(i);
                    if (e.name() == QLatin1String("ExposureMode")) {
                        for (int i = 0; i < e.keyCount(); i++) {
                            int mode = e.value(i);
                            if (m_camera->exposure()->isExposureModeSupported(static_cast<QCameraExposure::ExposureMode>(mode))) {
                                m_supportedExposureModes.append(mode);
                            }
                        }
                        break;
                    }
                }
            }

            m_supportedFocusModes.clear();
            if (m_camera) {

                // TODO: Use QMetaEnum::fromType<Class::EnumName>() once Qt Multimedia uses Q_ENUM
                QMetaObject meta = QCameraFocus::staticMetaObject;
                for (int i=0; i < meta.enumeratorCount(); ++i) {
                    QMetaEnum e = meta.enumerator(i);
                    if (e.name() == QLatin1String("FocusMode")) {
                        for (int i = 0; i < e.keyCount(); i++) {
                            int mode = e.value(i);
                            if (m_camera->focus()->isFocusModeSupported(static_cast<QCameraFocus::FocusMode>(mode))) {
                                m_supportedFocusModes.append(mode);
                            }
                        }
                        break;
                    }
                }
            }

            m_supportedFocusPointModes.clear();
            if (m_camera) {

                // TODO: Use QMetaEnum::fromType<Class::EnumName>() once Qt Multimedia uses Q_ENUM
                QMetaObject meta = QCameraFocus::staticMetaObject;
                for (int i=0; i < meta.enumeratorCount(); ++i) {
                    QMetaEnum e = meta.enumerator(i);
                    if (e.name() == QLatin1String("FocusPointMode")) {
                        for (int i = 0; i < e.keyCount(); i++) {
                            int mode = e.value(i);
                            if (m_camera->focus()->isFocusPointModeSupported(static_cast<QCameraFocus::FocusPointMode>(mode))) {
                                m_supportedFocusPointModes.append(mode);
                            }
                        }
                        break;
                    }
                }
            }

            m_supportedMeteringModes.clear();
            if (m_camera) {

                // TODO: Use QMetaEnum::fromType<Class::EnumName>() once Qt Multimedia uses Q_ENUM
                QMetaObject meta = QCameraExposure::staticMetaObject;
                for (int i=0; i < meta.enumeratorCount(); ++i) {
                    QMetaEnum e = meta.enumerator(i);
                    if (e.name() == QLatin1String("MeteringMode")) {
                        for (int i = 0; i < e.keyCount(); i++) {
                            int mode = e.value(i);
                            if (m_camera->exposure()->isMeteringModeSupported(static_cast<QCameraExposure::MeteringMode>(mode))) {
                                m_supportedMeteringModes.append(mode);
                            }
                        }
                        break;
                    }
                }
            }

            m_supportedFlashModes.clear();
            if (m_camera) {

                // TODO: Use QMetaEnum::fromType<Class::EnumName>() once Qt Multimedia uses Q_ENUM
                QMetaObject meta = QCameraExposure::staticMetaObject;
                for (int i=0; i < meta.enumeratorCount(); ++i) {
                    QMetaEnum e = meta.enumerator(i);
                    if (e.name() == QLatin1String("FlashMode")) {
                        for (int i = 0; i < e.keyCount(); i++) {
                            int mode = e.value(i);
                            if (m_camera->exposure()->isFlashModeSupported(static_cast<QCameraExposure::FlashModes>(mode))) {
                                m_supportedFlashModes.append(mode);
                            }
                        }
                        break;
                    }
                }
            }

            m_initialized = true;
        } else if (!m_camera) {
            m_supportedViewfinderResolutions.clear();
            m_supportedImageResolutions.clear();
            m_supportedVideoResolutions.clear();
            m_initialized = true;
        }

        if (m_initialized) {
            emit supportedViewfinderResolutionsChanged();
            emit supportedImageResolutionsChanged();
            emit supportedVideoResolutionsChanged();
            emit supportedIsoSensitivitiesChanged();
            emit supportedWhiteBalanceModesChanged();
            emit supportedExposureModesChanged();
            emit supportedFocusModesChanged();
            emit supportedFocusPointModesChanged();
            emit supportedMeteringModesChanged();
            emit supportedFlashModesChanged();
        }
    }
}

QVariantList CameraConfigs::supportedViewfinderResolutions() const
{
    return m_supportedViewfinderResolutions;
}

QVariantList CameraConfigs::supportedImageResolutions() const
{
    return m_supportedImageResolutions;
}

QVariantList CameraConfigs::supportedVideoResolutions() const
{
    return m_supportedVideoResolutions;
}

QVariantList CameraConfigs::supportedIsoSensitivities() const
{
    return m_supportedIsoSensitivities;
}

QVariantList CameraConfigs::supportedExposureModes() const
{
    return m_supportedExposureModes;
}

QVariantList CameraConfigs::supportedWhiteBalanceModes() const
{
    return m_supportedWhiteBalanceModes;
}

QVariantList CameraConfigs::supportedFocusModes() const
{
    return m_supportedFocusModes;
}

QVariantList CameraConfigs::supportedFocusPointModes() const
{
    return m_supportedFocusPointModes;
}

QVariantList CameraConfigs::supportedMeteringModes() const
{
    return m_supportedMeteringModes;
}

QVariantList CameraConfigs::supportedFlashModes() const
{
    return m_supportedFlashModes;
}
