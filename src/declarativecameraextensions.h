
#ifndef DECLARATIVECAMERAEXTENSIONS_H
#define DECLARATIVECAMERAEXTENSIONS_H

#include <QImageEncoderControl>
#include <QMediaMetaData>
#include <QMetaDataWriterControl>
#include <QVideoDeviceSelectorControl>
#include <QVideoEncoderSettingsControl>
#include <QCameraViewfinderSettingsControl>
#include <QMediaObject>
#include <QPointer>
#include <QQuickItem>
#include <QDateTime>

#include <private/qcamerasensorcontrol_p.h>

class DeclarativeCameraExtensions : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QObject *camera READ camera WRITE setCamera NOTIFY cameraChanged)
    Q_PROPERTY(QString device READ device WRITE setDevice NOTIFY deviceChanged)
    Q_PROPERTY(int rotation READ rotation WRITE setRotation NOTIFY rotationChanged)
    Q_PROPERTY(int orientation READ orientation NOTIFY orientationChanged)
    Q_PROPERTY(QSize viewfinderResolution READ viewfinderResolution WRITE setViewfinderResolution NOTIFY viewfinderResolutionChanged)
    Q_PROPERTY(QDateTime captureTime READ captureTime WRITE setCaptureTime NOTIFY captureTimeChanged)
    Q_PROPERTY(QVariant gpsLatitude READ gpsLatitude WRITE setGpsLatitude NOTIFY gpsLatitudeChanged)
    Q_PROPERTY(QVariant gpsLongitude READ gpsLongitude WRITE setGpsLongitude NOTIFY gpsLongitudeChanged)
    Q_PROPERTY(QVariant gpsAltitude READ gpsAltitude WRITE setGpsAltitude NOTIFY gpsAltitudeChanged)
public:
    DeclarativeCameraExtensions(QObject *parent = 0);
    ~DeclarativeCameraExtensions();

    QObject *camera() const;
    void setCamera(QObject *camera);

    QString device() const;
    void setDevice(const QString &device);

    int rotation() const;
    void setRotation(int rotation);

    int orientation() const;

    QSize viewfinderResolution() const;
    void setViewfinderResolution(const QSize &resolution);

    QDateTime captureTime() const;
    void setCaptureTime(const QDateTime &time);

    QVariant gpsLatitude() const { return metaData(QMediaMetaData::GPSLatitude); }
    void setGpsLatitude(const QVariant &latitude) {
        setMetaData(QMediaMetaData::GPSLatitude, latitude);
        emit gpsLatitudeChanged();
    }

    QVariant gpsLongitude() const { return metaData(QMediaMetaData::GPSLongitude); }
    void setGpsLongitude(const QVariant &longitude) {
        setMetaData(QMediaMetaData::GPSLongitude, longitude);
        emit gpsLongitudeChanged();
    }

    QVariant gpsAltitude() const { return metaData(QMediaMetaData::GPSAltitude); }
    void setGpsAltitude(const QVariant &altitude) {
        setMetaData(QMediaMetaData::GPSAltitude, altitude);
        emit gpsAltitudeChanged();
    }

    Q_INVOKABLE void disableNotifications(QQuickItem *item, bool disable);

signals:
    void cameraChanged();
    void deviceChanged();
    void rotationChanged();
    void orientationChanged();
    void viewfinderResolutionChanged();
    void captureTimeChanged();

    void gpsLatitudeChanged();
    void gpsLongitudeChanged();
    void gpsAltitudeChanged();

private slots:
    void sensorPropertyChanged(QCameraSensorControl::Property);

private:
    void updateDevice();

    QVariant metaData(const QString &key) const;
    void setMetaData(const QString &key, const QVariant &value);

    QObject *m_camera;
    QPointer<QMediaObject> m_mediaObject;
    QVideoDeviceSelectorControl *m_deviceControl;
    QImageEncoderControl *m_imageEncoderControl;
    QVideoEncoderSettingsControl *m_videoEncoderControl;
    QMetaDataWriterControl *m_metaDataControl;
    QCameraViewfinderSettingsControl *m_viewfinderSettingsControl;
    QCameraSensorControl *m_sensorControl;
    QSize m_viewfinderResolution;
    QDateTime m_captureTime;
    QString m_device;
    int m_rotation;
    int m_orientation;
};

#endif
