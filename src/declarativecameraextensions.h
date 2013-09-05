
#ifndef DECLARATIVECAMERAEXTENSIONS_H
#define DECLARATIVECAMERAEXTENSIONS_H

#include <QImageEncoderControl>
#include <QMetaDataWriterControl>
#include <QVideoDeviceSelectorControl>
#include <QVideoEncoderSettingsControl>
#include <QMediaObject>
#include <QPointer>

class DeclarativeCameraExtensions : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QObject *camera READ camera WRITE setCamera NOTIFY cameraChanged)
    Q_PROPERTY(Face face READ face WRITE setFace NOTIFY faceChanged)
    Q_PROPERTY(int rotation READ rotation WRITE setRotation NOTIFY rotationChanged)
    Q_ENUMS(Face)
    Q_ENUMS(AspectRatio)
public:
    enum Face {
        Back,
        Front
    };

    enum AspectRatio {
        AspectRatio_4_3,
        AspectRatio_16_9
    };

    DeclarativeCameraExtensions(QObject *parent = 0);
    ~DeclarativeCameraExtensions();

    QObject *camera() const;
    void setCamera(QObject *camera);

    Face face() const;
    void setFace(Face face);

    int rotation() const;
    void setRotation(int rotation);

signals:
    void cameraChanged();
    void faceChanged();
    void rotationChanged();

private:
    void updateDevice();

    QObject *m_camera;
    QPointer<QMediaObject> m_mediaObject;
    QVideoDeviceSelectorControl *m_deviceControl;
    QImageEncoderControl *m_imageEncoderControl;
    QVideoEncoderSettingsControl *m_videoEncoderControl;
    QMetaDataWriterControl *m_metaDataControl;
    Face m_face;
    int m_rotation;
};

#endif
