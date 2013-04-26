#ifndef DECLARATIVEFLASH_H
#define DECLARATIVEFLASH_H

#include <QCameraFlashControl>

#include "declarativecamera.h"

class DeclarativeFlash : public QObject
{
    Q_OBJECT
    Q_PROPERTY(DeclarativeCamera::FlashMode flashMode READ mode WRITE setMode NOTIFY modeChanged)
    Q_ENUMS(DeclarativeCamera::FlashMode)
public:
    DeclarativeFlash(QCamera *camera, QObject *parent = 0);
    ~DeclarativeFlash();

    DeclarativeCamera::FlashMode mode() const;
    void setMode(DeclarativeCamera::FlashMode mode);

    bool isReady() const;

Q_SIGNALS:
    void modeChanged();
    void readyChanged();

private:
    QCamera *m_camera;
    QCameraFlashControl *m_control;
};

#endif
