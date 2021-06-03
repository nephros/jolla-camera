#ifndef CAMERACONFIGS_H
#define CAMERACONFIGS_H

#include <QObject>
#include <QSize>
#include <QVariantList>

QT_BEGIN_NAMESPACE
class QCamera;
class QCameraImageCapture;
class QMediaRecorder;
QT_END_NAMESPACE

class CameraConfigs : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QObject * camera READ camera WRITE setCamera NOTIFY cameraChanged)

    // TODO: Replace QVariantList here with QList<QSize> on newer Qt
    Q_PROPERTY(QVariantList supportedViewfinderResolutions READ supportedViewfinderResolutions NOTIFY supportedViewfinderResolutionsChanged)
    Q_PROPERTY(QVariantList supportedImageResolutions READ supportedImageResolutions NOTIFY supportedImageResolutionsChanged)
    Q_PROPERTY(QVariantList supportedVideoResolutions READ supportedVideoResolutions NOTIFY supportedVideoResolutionsChanged)
    Q_PROPERTY(QVariantList supportedIsoSensitivities READ supportedIsoSensitivities NOTIFY supportedIsoSensitivitiesChanged)
    Q_PROPERTY(QVariantList supportedWhiteBalanceModes READ supportedWhiteBalanceModes NOTIFY supportedWhiteBalanceModesChanged)
    Q_PROPERTY(QVariantList supportedExposureModes READ supportedExposureModes NOTIFY supportedExposureModesChanged)
    Q_PROPERTY(QVariantList supportedFocusModes READ supportedFocusModes NOTIFY supportedFocusModesChanged)
    Q_PROPERTY(QVariantList supportedFocusPointModes READ supportedFocusPointModes NOTIFY supportedFocusPointModesChanged)
    Q_PROPERTY(QVariantList supportedMeteringModes READ supportedMeteringModes NOTIFY supportedMeteringModesChanged)
    Q_PROPERTY(QVariantList supportedFlashModes READ supportedFlashModes NOTIFY supportedFlashModesChanged)
    Q_PROPERTY(QVariantList supportedColorFilters READ supportedColorFilters NOTIFY supportedColorFiltersChanged)

public:
    enum AspectRatio {
        AspectRatio_4_3,
        AspectRatio_16_9
    };

    Q_ENUM(AspectRatio)

    CameraConfigs(QObject *parent = 0);
    ~CameraConfigs();

    QList<QObject *> exposedItems() const;

    QVariantList supportedViewfinderResolutions() const;
    QVariantList supportedImageResolutions() const;
    QVariantList supportedVideoResolutions() const;
    QVariantList supportedIsoSensitivities() const;
    QVariantList supportedWhiteBalanceModes() const;
    QVariantList supportedExposureModes() const;
    QVariantList supportedFocusModes() const;
    QVariantList supportedFocusPointModes() const;
    QVariantList supportedMeteringModes() const;
    QVariantList supportedFlashModes() const;
    QVariantList supportedColorFilters() const;


    void setCamera(QObject *camera);
    QObject *camera() const;

signals:
    void cameraChanged();
    void supportedViewfinderResolutionsChanged();
    void supportedImageResolutionsChanged();
    void supportedVideoResolutionsChanged();
    void supportedIsoSensitivitiesChanged();
    void supportedWhiteBalanceModesChanged();
    void supportedExposureModesChanged();
    void supportedFocusModesChanged();
    void supportedFocusPointModesChanged();
    void supportedMeteringModesChanged();
    void supportedFlashModesChanged();
    void supportedColorFiltersChanged();
private slots:
    void handleStatus();
    void handleState();
private:
    bool m_initialized = true;
    QCamera *m_camera = nullptr;
    QObject *m_qmlCamera = nullptr;
    QVariantList m_supportedViewfinderResolutions;
    QVariantList m_supportedImageResolutions;
    QVariantList m_supportedVideoResolutions;
    QVariantList m_supportedIsoSensitivities;
    QVariantList m_supportedWhiteBalanceModes;
    QVariantList m_supportedExposureModes;
    QVariantList m_supportedFocusModes;
    QVariantList m_supportedFocusPointModes;
    QVariantList m_supportedMeteringModes;
    QVariantList m_supportedFlashModes;
    QVariantList m_supportedColorFilters;
};

#endif // CAMERACONFIGS_H

