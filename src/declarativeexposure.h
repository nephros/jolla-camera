
#ifndef DECLARATIVEEXPOSURE_H
#define DECLARATIVEEXPOSURE_H

#include <QCameraExposureControl>

#include "declarativecamera.h"

class DeclarativeExposure : public QObject
{
    Q_OBJECT
    Q_PROPERTY(qreal exposureCompensation READ compensation WRITE setCompensation NOTIFY compensationChanged)
    Q_PROPERTY(DeclarativeCamera::ExposureMode exposureMode READ mode WRITE setMode NOTIFY modeChanged)
    Q_PROPERTY(int manualIso READ iso WRITE setIso RESET setAutoIsoSensitivity NOTIFY isoChanged)
    Q_PROPERTY(bool automaticIso READ hasAutomaticIso NOTIFY automaticIsoChanged)
    Q_PROPERTY(QVariantList supportedIso READ supportedIso NOTIFY supportedIsoChanged)
    Q_ENUMS(DeclarativeCamera::ExposureMode)
public:
    DeclarativeExposure(QCamera *camera, QObject *parent = 0);
    ~DeclarativeExposure();

    qreal compensation() const;
    void setCompensation(qreal compensation);

    DeclarativeCamera::ExposureMode mode() const;
    void setMode(DeclarativeCamera::ExposureMode mode);

    int iso() const;
    void setIso(int iso);
    void setAutoIsoSensitivity();
    bool hasAutomaticIso() const;

    QVariantList supportedIso() const;

Q_SIGNALS:
    void compensationChanged();
    void modeChanged();
    void isoChanged();
    void automaticIsoChanged();
    void supportedIsoChanged();

private Q_SLOTS:
    void parameterChanged(int parameter);
    void parameterRangeChanged(int parameter);

private:
    QCamera *m_camera;
    QCameraExposureControl *m_control;
    bool m_autoIso;
};


#endif
