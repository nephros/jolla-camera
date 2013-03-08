
#ifndef DECLARATIVECAMERA_H
#define DECLARATIVECAMERA_H

#include <qdeclarative.h>
#include <QDeclarativeParserStatus>

#include <QCamera>
#include <QCameraImageCaptureControl>
#include <QMediaRecorderControl>

class DeclarativeCamera : public QObject, public QDeclarativeParserStatus
{
    Q_OBJECT
    Q_PROPERTY(Status status READ status NOTIFY statusChanged)
    Q_PROPERTY(CaptureMode captureMode READ captureMode WRITE setCaptureMode NOTIFY captureModeChanged)
    Q_ENUMS(Status)
    Q_ENUMS(CaptureMode)
    Q_INTERFACES(QDeclarativeParserStatus)
public:
    enum Status
    {
        Null,
        Previewing,
        Capturing,
        Recording,
        Suspended,
        Error
    };

    enum CaptureMode
    {
        Still = QCamera::CaptureStillImage,
        Video = QCamera::CaptureVideo
    };

    DeclarativeCamera(QObject *parent = 0);
    ~DeclarativeCamera();

    void classBegin();
    void componentComplete();

    Status status() const;

    CaptureMode captureMode() const;
    void setCaptureMode(CaptureMode mode);

    QCamera *camera() const;

public Q_SLOTS:
    void capture();
    void record();
    void stop();

Q_SIGNALS:
    void statusChanged();
    void captureModeChanged();

private Q_SLOTS:
    void cameraStateChanged(QCamera::State state);
    void cameraStatusChanged(QCamera::Status status);
    void cameraError(QCamera::Error error);
    void recorderStateChanged(QMediaRecorder::State state);
    void imageSaved(int,const QString &fileName);

private:
    void requestControls();

    QCamera m_camera;
    QCameraImageCaptureControl *m_captureControl;
    QMediaRecorderControl *m_recorderControl;
    Status m_status;
};

#endif
