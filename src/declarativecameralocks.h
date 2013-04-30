
#ifndef DECLARATIVECAMERALOCKS_H
#define DECLARATIVECAMERALOCKS_H

#include <QCameraLocksControl>

class DeclarativeCameraLocks : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QObject *camera READ camera WRITE setCamera NOTIFY cameraChanged)
    Q_PROPERTY(Status focusStatus READ focusStatus NOTIFY focusStatusChanged)
    Q_PROPERTY(Status exposureStatus READ exposureStatus NOTIFY exposureStatusChanged)
    Q_PROPERTY(Status whiteBalanceStatus READ whiteBalanceStatus NOTIFY whiteBalanceStatusChanged)
    Q_ENUMS(Status)
public:
    enum Status {
        Unlocked    = QCamera::Unlocked,
        Searching   = QCamera::Searching,
        Locked      = QCamera::Locked
    };

    DeclarativeCameraLocks(QObject *parent = 0);
    ~DeclarativeCameraLocks();

    QObject *camera() const;
    void setCamera(QObject *camera);

    Status focusStatus() const;
    Status exposureStatus() const;
    Status whiteBalanceStatus() const;

public slots:
    void lockFocus();
    void unlockFocus();
    void lockExposure();
    void unlockExposure();
    void lockWhiteBalance();
    void unlockWhiteBalance();

signals:
    void cameraChanged();
    void focusStatusChanged();
    void exposureStatusChanged();
    void whiteBalanceStatusChanged();

private slots:
    void lockStatusChanged(QCamera::LockType type);

private:
    QObject *m_camera;
    QMediaObject *m_mediaObject;
    QCameraLocksControl *m_locksControl;
};

#endif
