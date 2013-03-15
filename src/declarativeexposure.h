
#ifndef DECLARATIVEEXPOSURE_H
#define DECLARATIVEEXPOSURE_H

#include <QCameraExposureControl>

class DeclarativeExposure : public QObject
{
    Q_OBJECT
    Q_PROPERTY(qreal compensation READ compensation WRITE setCompensation NOTIFY compensationChanged)
public:
    DeclarativeExposure(QCamera *camera, QObject *parent = 0);
    ~DeclarativeExposure();

    qreal compensation() const;
    void setCompensation(qreal compensation);

Q_SIGNALS:
    void compensationChanged();

private Q_SLOTS:
    void parameterChanged(int parameter);

private:
    QCamera *m_camera;
    QCameraExposureControl *m_control;
};


#endif
