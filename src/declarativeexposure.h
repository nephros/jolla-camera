
#ifndef DECLARATIVEEXPOSURE_H
#define DECLARATIVEEXPOSURE_H

#include <QCameraExposureControl>

class DeclarativeExposure : public QObject
{
    Q_OBJECT
    Q_PROPERTY(qreal compensation READ compensation WRITE setCompensation NOTIFY compensationChanged)
    Q_PROPERTY(int iso READ iso WRITE setIso RESET resetIso NOTIFY isoChanged)
    Q_PROPERTY(bool automaticIso READ hasAutomaticIso NOTIFY automaticIsoChanged)
    Q_PROPERTY(QVariantList supportedIso READ supportedIso NOTIFY supportedIsoChanged)
public:
    DeclarativeExposure(QCamera *camera, QObject *parent = 0);
    ~DeclarativeExposure();

    qreal compensation() const;
    void setCompensation(qreal compensation);

    int iso() const;
    void setIso(int iso);
    void resetIso();
    bool hasAutomaticIso() const;

    QVariantList supportedIso() const;

Q_SIGNALS:
    void compensationChanged();
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
