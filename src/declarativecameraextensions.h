
#ifndef DECLARATIVECAMERAEXTENSIONS_H
#define DECLARATIVECAMERAEXTENSIONS_H

#include <QVideoDeviceControl>
#include <QMediaObject>

class DeclarativeCameraExtensions : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QObject *camera READ camera WRITE setCamera NOTIFY cameraChanged)
    Q_PROPERTY(Face face READ face WRITE setFace NOTIFY faceChanged)
    Q_ENUMS(Face)
public:
    enum Face {
        Back,
        Front
    };

    DeclarativeCameraExtensions(QObject *parent = 0);
    ~DeclarativeCameraExtensions();

    QObject *camera() const;
    void setCamera(QObject *camera);

    Face face() const;
    void setFace(Face face);

signals:
    void cameraChanged();
    void faceChanged();

private:
    void updateDevice();

    QObject *m_camera;
    QMediaObject *m_mediaObject;
    QVideoDeviceControl *m_deviceControl;
    Face m_face;
};

#endif
