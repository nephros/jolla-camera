#include "declarativecamera.h"

#include <QDeclarativeInfo>
#include <QDateTime>

DeclarativeCamera::DeclarativeCamera(QObject *parent)
    : QObject(parent)
    , m_captureControl(0)
    , m_recorderControl(0)
    , m_status(Null)
{
    connect(&m_camera, SIGNAL(captureModeChanged(QCamera::CaptureMode)),
            this, SIGNAL(captureModeChanged()));
    connect(&m_camera, SIGNAL(stateChanged(QCamera::State)),
            this, SLOT(cameraStateChanged(QCamera::State)));
    connect(&m_camera, SIGNAL(statusChanged(QCamera::Status)),
            this, SLOT(cameraStatusChanged(QCamera::Status)));
    connect(&m_camera, SIGNAL(error(QCamera::Error)),
            this, SLOT(cameraError(QCamera::Error)));
}

DeclarativeCamera::~DeclarativeCamera()
{
}

void DeclarativeCamera::classBegin()
{
}

void DeclarativeCamera::componentComplete()
{
    requestControls();
    m_camera.load();
}

DeclarativeCamera::Status DeclarativeCamera::status() const
{
    return m_status;
}

DeclarativeCamera::CaptureMode DeclarativeCamera::captureMode() const
{
    return CaptureMode(m_camera.captureMode());
}

void DeclarativeCamera::setCaptureMode(CaptureMode mode)
{
    if (QCamera::CaptureMode(mode) != m_camera.captureMode()) {
        if (m_captureControl) {
            disconnect(m_captureControl, SIGNAL(imageSaved(int,QString)),
                       this, SLOT(imageSaved(int,QString)));
            m_camera.service()->releaseControl(m_captureControl);
            m_captureControl = 0;
        } else if (m_recorderControl) {
            disconnect(m_recorderControl, SIGNAL(stateChanged(QMediaRecorder::State)),
                    this, SLOT(recorderStateChanged(QMediaRecorder::State)));
            m_camera.service()->releaseControl(m_recorderControl);
            m_recorderControl = 0;
        }

        m_camera.setCaptureMode(QCamera::CaptureMode(mode));

        requestControls();
    }
}

void DeclarativeCamera::requestControls()
{
    if (m_camera.captureMode() == QCamera::CaptureStillImage && !m_captureControl) {
        if ((m_captureControl = m_camera.service()->requestControl<QCameraImageCaptureControl *>())) {
            connect(m_captureControl, SIGNAL(imageSaved(int,QString)),
                    this, SLOT(imageSaved(int,QString)));
        } else {
            qmlInfo(this) << "Image capture is not supported by the camera";
        }
    } else if (m_camera.captureMode() == QCamera::CaptureVideo && !m_recorderControl) {
        if ((m_recorderControl = m_camera.service()->requestControl<QMediaRecorderControl *>())) {
            connect(m_recorderControl, SIGNAL(stateChanged(QMediaRecorder::State)),
                    this, SLOT(recorderStateChanged(QMediaRecorder::State)));
        } else {
            qmlInfo(this) << "Video recording is not supported by the camera";
        }
    }
}

QCamera *DeclarativeCamera::camera() const
{
    return const_cast<QCamera *>(&m_camera);
}

void DeclarativeCamera::capture()
{
    if (m_captureControl) {
        const QString fileName = QDateTime::currentDateTimeUtc().toString(
                    QLatin1String("'/home/nemo/Pictures/'yyyyMMdd-hhmmss'.jpg'"));
        m_status = Capturing;
        m_captureControl->capture(fileName);
        emit statusChanged();
    }
}

void DeclarativeCamera::record()
{
    if (m_recorderControl) {
        const QString fileName = QDateTime::currentDateTimeUtc().toString(
                    QLatin1String("'/home/nemo/Videos/'yyyyMMdd-hhmmss'.mp4'"));
        m_recorderControl->setOutputLocation(QUrl::fromLocalFile(fileName));
        m_recorderControl->record();
    }
}

void DeclarativeCamera::stop()
{
    if (m_recorderControl) {
        m_recorderControl->stop();
    } else if (m_captureControl) {
        m_captureControl->cancelCapture();
    }
}

void DeclarativeCamera::cameraStateChanged(QCamera::State state)
{
    switch (state) {
    case QCamera::LoadedState:
        m_camera.start();
        break;
    case QCamera::UnloadedState:
        break;
    case QCamera::ActiveState:
        if (m_status == Null || m_status == Error) {
            m_status = Previewing;
            emit statusChanged();
        }
        break;
    default:
         break;
    }
}

void DeclarativeCamera::cameraStatusChanged(QCamera::Status)
{
}

void DeclarativeCamera::cameraError(QCamera::Error error)
{
    qmlInfo(this) << "The camera reported an error" << int(error);
    if (m_status != Error) {
        m_status = Error;
        emit statusChanged();
    }
}

void DeclarativeCamera::recorderStateChanged(QMediaRecorder::State state)
{
    switch (state) {
    case QMediaRecorder::StoppedState:
        {
            Status status = m_camera.state() == QCamera::ActiveState
                    ? Previewing
                    : Null;
            if (m_status != status) {
                m_status = status;
                emit statusChanged();
            }
        }
    case QMediaRecorder::PausedState:
        if (m_status != Previewing) {
            m_status = Previewing;
            emit statusChanged();
        }
    case QMediaRecorder::RecordingState:
        if (m_status != Recording) {
            m_status = Recording;
            emit statusChanged();
        }
    default:
        break;
    }
}

void DeclarativeCamera::imageSaved(int,const QString &)
{
    if (m_status == Capturing) {
        m_status = Previewing;
        emit statusChanged();
    }
}
