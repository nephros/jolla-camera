#ifndef DECLARATIVEFLASH_H
#define DECLARATIVEFLASH_H

#include <QCameraFlashControl>

class DeclarativeFlash : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Mode mode READ mode WRITE setMode NOTIFY modeChanged)
    Q_ENUMS(Mode)
public:
    enum Mode
    {
        Off     = QCameraExposure::FlashOff,
        On      = QCameraExposure::FlashOn,
        Auto    = QCameraExposure::FlashAuto
    };

    DeclarativeFlash(QCamera *camera, QObject *parent = 0);
    ~DeclarativeFlash();

    Mode mode() const;
    void setMode(Mode mode);

    bool isReady() const;

Q_SIGNALS:
    void modeChanged();
    void readyChanged();

private:
    QCamera *m_camera;
    QCameraFlashControl *m_control;
};

#endif
