#include "declarativecamera.h"

#include "declarativeexposure.h"
#include "declarativeflash.h"
#include "declarativefocus.h"

#include <QDeclarativeInfo>
#include <QDateTime>
#include <QDir>
#include <QImageEncoderSettings>
#include <QVideoEncoderSettings>

DeclarativeCamera::DeclarativeCamera(QObject *parent)
    : QObject(parent)
    , m_imageCapture(0)
    , m_videoRecorder(0)
    , m_exposure(0)
    , m_flash(0)
    , m_focus(0)
    , m_imageProcessing(0)
{
    connect(&m_camera, SIGNAL(captureModeChanged(QCamera::CaptureMode)),
            this, SIGNAL(captureModeChanged()));
    connect(&m_camera, SIGNAL(stateChanged(QCamera::State)), this, SIGNAL(cameraStateChanged()));
    connect(&m_camera, SIGNAL(statusChanged(QCamera::Status)), this, SIGNAL(cameraStatusChanged()));
}

DeclarativeCamera::~DeclarativeCamera()
{
    delete m_imageCapture;
    delete m_videoRecorder;
    delete m_flash;
    delete m_exposure;
    delete m_imageProcessing;
}

DeclarativeCamera::Status DeclarativeCamera::status() const
{
    return Status(m_camera.status());
}

DeclarativeCamera::CaptureMode DeclarativeCamera::captureMode() const
{
    return CaptureMode(m_camera.captureMode());
}

void DeclarativeCamera::setCaptureMode(CaptureMode mode)
{
    if (QCamera::CaptureMode(mode) != m_camera.captureMode()) {
        m_camera.setCaptureMode(QCamera::CaptureMode(mode));
    }
}

DeclarativeCamera::State DeclarativeCamera::state() const
{
    return State(m_camera.state());
}

void DeclarativeCamera::setState(DeclarativeCamera::State state)
{
    switch (state) {
    case LoadedState:
        if (m_camera.state() == QCamera::ActiveState) {
            m_camera.stop();
        } else {
            m_camera.load();
        }
        break;
    case UnloadedState:
        m_camera.unload();
        break;
    case ActiveState:
        m_camera.start();
        break;
    }
}

DeclarativeImageCapture *DeclarativeCamera::imageCapture()
{
    if (!m_imageCapture) {
        m_imageCapture = new DeclarativeImageCapture(&m_camera, this);
    }
    return m_imageCapture;
}

DeclarativeVideoRecorder *DeclarativeCamera::videoRecorder()
{
    if (!m_videoRecorder) {
        m_videoRecorder = new DeclarativeVideoRecorder(&m_camera, this);
    }
    return m_videoRecorder;
}

DeclarativeExposure *DeclarativeCamera::exposure()
{
    if (!m_exposure) {
        m_exposure = new DeclarativeExposure(&m_camera, this);
    }
    return m_exposure;
}

DeclarativeFlash *DeclarativeCamera::flash()
{
    if (!m_flash) {
        m_flash = new DeclarativeFlash(&m_camera, this);
    }
    return m_flash;
}

DeclarativeFocus *DeclarativeCamera::focus()
{
    if (!m_focus) {
        m_focus = new DeclarativeFocus(&m_camera, this);
    }
    return m_focus;
}


DeclarativeImageProcessing *DeclarativeCamera::imageProcessing()
{
    if (!m_imageProcessing) {
        m_imageProcessing = new DeclarativeImageProcessing(&m_camera, this);
    }
    return m_imageProcessing;
}

QCamera *DeclarativeCamera::camera() const
{
    return const_cast<QCamera *>(&m_camera);
}

DeclarativeImageCapture::DeclarativeImageCapture(QCamera *camera, QObject *parent)
    : QObject(parent)
    , m_camera(camera)
    , m_imageEncoderControl(0)
{
    if (m_camera->service()
            && (m_captureControl = m_camera->service()->requestControl<QCameraImageCaptureControl *>())) {
        // connections.
    }
    if (m_camera->service()
            && (m_imageEncoderControl = m_camera->service()->requestControl<QImageEncoderControl *>())) {
    }
}

DeclarativeImageCapture::~DeclarativeImageCapture()
{
    if (m_captureControl) {
        m_camera->service()->releaseControl(m_captureControl);
    }
}

void DeclarativeImageCapture::capture()
{
    if (m_captureControl) {
        const QString fileName = QDateTime::currentDateTimeUtc().toString(
                QLatin1String("'/home/nemo/Pictures/Camera/'yyyyMMdd-hhmmss'.jpg'"));
        m_captureControl->capture(fileName);
    }
}

QSize DeclarativeImageCapture::resolution() const
{
    return m_imageEncoderControl
            ? m_imageEncoderControl->imageSettings().resolution()
            : QSize();
}

void DeclarativeImageCapture::setResolution(const QSize &resolution)
{
    if (m_imageEncoderControl) {
        QImageEncoderSettings settings = m_imageEncoderControl->imageSettings();
        settings.setResolution(resolution);
        m_imageEncoderControl->setImageSettings(settings);
        emit resolutionChanged();
    }
}

DeclarativeVideoRecorder::DeclarativeVideoRecorder(QCamera *camera, QObject *parent)
    : QObject(parent)
    , m_camera(camera)
    , m_recorderControl(0)
    , m_videoEncoderControl(0)
{
    if (m_camera->service()
            && (m_recorderControl = m_camera->service()->requestControl<QMediaRecorderControl *>())) {
        connect(m_recorderControl, SIGNAL(stateChanged(QMediaRecorder::State)),
                this, SIGNAL(stateChanged()));
        connect(m_recorderControl, SIGNAL(durationChanged(qint64)), this, SIGNAL(durationChanged()));
    }
    if (m_camera->service()
            && (m_videoEncoderControl = m_camera->service()->requestControl<QVideoEncoderControl *>())) {
    }
}

DeclarativeVideoRecorder::~DeclarativeVideoRecorder()
{
    if (m_recorderControl) {
        m_camera->service()->releaseControl(m_recorderControl);
    }
}

DeclarativeVideoRecorder::State DeclarativeVideoRecorder::state() const
{
    return m_recorderControl ? State(m_recorderControl->state()) : StoppedState;
}

void DeclarativeVideoRecorder::record()
{
    if (m_recorderControl) {
        const QString fileName = QDateTime::currentDateTimeUtc().toString(
                    QLatin1String("'/home/nemo/Videos/Camera/'yyyyMMdd-hhmmss'.mkv'"));
        m_recorderControl->setOutputLocation(fileName);
        m_recorderControl->record();
    }
}

void DeclarativeVideoRecorder::stop()
{
    if (m_recorderControl) {
        m_recorderControl->stop();
    }
}

QSize DeclarativeVideoRecorder::resolution() const
{
    return m_videoEncoderControl
            ? m_videoEncoderControl->videoSettings().resolution()
            : QSize();
}

void DeclarativeVideoRecorder::setResolution(const QSize &resolution)
{
    if (m_videoEncoderControl) {
        QVideoEncoderSettings settings = m_videoEncoderControl->videoSettings();
        settings.setResolution(resolution);
        m_videoEncoderControl->setVideoSettings(settings);
        emit resolutionChanged();
    }
}

qreal DeclarativeVideoRecorder::frameRate() const
{
    return m_videoEncoderControl
            ? m_videoEncoderControl->videoSettings().frameRate()
            : 15;
}

void DeclarativeVideoRecorder::setFrameRate(qreal rate)
{
    if (m_videoEncoderControl) {
        QVideoEncoderSettings settings = m_videoEncoderControl->videoSettings();
        settings.setFrameRate(rate);
        m_videoEncoderControl->setVideoSettings(settings);
        emit resolutionChanged();
    }
}

qint64 DeclarativeVideoRecorder::duration() const
{
    return m_recorderControl ? m_recorderControl->duration() : 0;
}

DeclarativeImageProcessing::DeclarativeImageProcessing(QCamera *camera, QObject *parent)
    : QObject(parent)
    , m_camera(camera)
{
    if (m_camera->service()
            && (m_imageProcessingControl = m_camera->service()->requestControl<QCameraImageProcessingControl *>())) {
        // connections.
    }
}

DeclarativeImageProcessing::~DeclarativeImageProcessing()
{
    if (m_imageProcessingControl) {
        m_camera->service()->releaseControl(m_imageProcessingControl);
    }
}

DeclarativeImageProcessing::WhiteBalanceMode DeclarativeImageProcessing::whiteBalanceMode() const
{
    return m_imageProcessingControl
            ? WhiteBalanceMode(m_imageProcessingControl->whiteBalanceMode())
            : WhiteBalanceAuto;
}

void DeclarativeImageProcessing::setWhiteBalanceMode(WhiteBalanceMode mode)
{
    if (m_imageProcessingControl) {
        m_imageProcessingControl->setWhiteBalanceMode(QCameraImageProcessing::WhiteBalanceMode(mode));
        emit whiteBalanceModeChanged();
    }
}
