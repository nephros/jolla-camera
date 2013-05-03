
#ifndef DECLARATIVECAMERA_H
#define DECLARATIVECAMERA_H

#include <qdeclarative.h>
#include <QDeclarativeParserStatus>

#include <QCamera>
#include <QCameraExposure>
#include <QCameraImageCaptureControl>
#include <QCameraImageProcessingControl>
#include <QImageEncoderControl>
#include <QMediaRecorderControl>
#include <QVideoEncoderControl>

class DeclarativeExposure;
class DeclarativeFlash;
class DeclarativeFocus;
class DeclarativeImageProcessing;
class DeclarativeImageCapture;
class DeclarativeVideoRecorder;

class DeclarativeCamera : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Status cameraStatus READ status NOTIFY cameraStatusChanged)
    Q_PROPERTY(State cameraState READ state WRITE setState NOTIFY cameraStateChanged)
    Q_PROPERTY(CaptureMode captureMode READ captureMode WRITE setCaptureMode NOTIFY captureModeChanged)
    Q_PROPERTY(DeclarativeImageCapture *imageCapture READ imageCapture CONSTANT)
    Q_PROPERTY(DeclarativeVideoRecorder *videoRecorder READ videoRecorder CONSTANT)
    Q_PROPERTY(DeclarativeExposure *exposure READ exposure CONSTANT)
    Q_PROPERTY(DeclarativeFlash *flash READ flash CONSTANT)
    Q_PROPERTY(DeclarativeFocus *focus READ focus CONSTANT)
    Q_PROPERTY(DeclarativeImageProcessing *imageProcessing READ imageProcessing CONSTANT)
    Q_PROPERTY(QVariant mediaObject READ mediaObject CONSTANT)
    Q_ENUMS(Status)
    Q_ENUMS(State)
    Q_ENUMS(CaptureMode)
    Q_ENUMS(FlashMode)
    Q_ENUMS(ExposureMode)
    Q_ENUMS(FocusMode)
    Q_ENUMS(FocusPointMode)
    Q_ENUMS(MeteringMode)
public:
    enum Status
    {
        UnavailableStatus = QCamera::UnavailableStatus,
        UnloadedStatus = QCamera::UnloadedStatus,
        LoadingStatus = QCamera::LoadingStatus,
        LoadedStatus = QCamera::LoadedStatus,
        StandbyStatus = QCamera::StandbyStatus,
        StartingStatus = QCamera::StartingStatus,
        ActiveStatus = QCamera::ActiveStatus
    };

    enum State
    {
        UnloadedState = QCamera::UnloadedState,
        LoadedState = QCamera::LoadedState,
        ActiveState = QCamera::ActiveState
    };

    enum CaptureMode
    {
        CaptureStillImage = QCamera::CaptureStillImage,
        CaptureVideo = QCamera::CaptureVideo
    };

    enum FlashMode
    {
        FlashAuto = QCameraExposure::FlashAuto,
        FlashOff = QCameraExposure::FlashOff,
        FlashOn = QCameraExposure::FlashOn,
        FlashRedEyeReduction = QCameraExposure::FlashRedEyeReduction,
        FlashFill = QCameraExposure::FlashFill,
        FlashTorch = QCameraExposure::FlashTorch,
        FlashSlowSyncFrontCurtain = QCameraExposure::FlashSlowSyncFrontCurtain,
        FlashSlowSyncRearCurtain = QCameraExposure::FlashSlowSyncRearCurtain,
        FlashManual = QCameraExposure::FlashManual
    };

    enum ExposureMode
    {
        ExposureAuto = QCameraExposure::ExposureAuto,
        ExposureManual = QCameraExposure::ExposureManual,
        ExposurePortrait = QCameraExposure::ExposurePortrait,
        ExposureNight = QCameraExposure::ExposureNight,
        ExposureBacklight = QCameraExposure::ExposureBacklight,
        ExposureSpotlight = QCameraExposure::ExposureSpotlight,
        ExposureSports = QCameraExposure::ExposureSports,
        ExposureSnow = QCameraExposure::ExposureSnow,
        ExposureBeach = QCameraExposure::ExposureBeach,
        ExposureLargeAperture = QCameraExposure::ExposureLargeAperture,
        ExposureSmallAperture = QCameraExposure::ExposureSmallAperture,
        ExposureModeVendor = QCameraExposure::ExposureModeVendor
    };

    enum FocusMode
    {
        FocusManual = QCameraFocus::ManualFocus,
        FocusHyperfocal = QCameraFocus::HyperfocalFocus,
        FocusInfinity = QCameraFocus::InfinityFocus,
        FocusAuto = QCameraFocus::AutoFocus,
        FocusContinuous = QCameraFocus::ContinuousFocus,
        FocusMacro = QCameraFocus::MacroFocus
    };

    enum FocusPointMode
    {
        FocusPointAuto = QCameraFocus::FocusPointAuto,
        FocusPointCenter = QCameraFocus::FocusPointCenter,
        FocusPointFaceDetection = QCameraFocus::FocusPointFaceDetection,
        FocusPointCustom = QCameraFocus::FocusPointCustom
    };

    enum MeteringMode
    {
        MeteringMatrix = QCameraExposure::MeteringMatrix,
        MeteringAverage = QCameraExposure::MeteringAverage,
        MeteringSpot = QCameraExposure::MeteringSpot
    };

    DeclarativeCamera(QObject *parent = 0);
    ~DeclarativeCamera();

    Status status() const;

    State state() const;
    void setState(DeclarativeCamera::State state);

    CaptureMode captureMode() const;
    void setCaptureMode(CaptureMode mode);

    DeclarativeImageCapture *imageCapture();
    DeclarativeVideoRecorder *videoRecorder();
    DeclarativeExposure *exposure();
    DeclarativeFlash *flash();
    DeclarativeFocus *focus();
    DeclarativeImageProcessing *imageProcessing();

    QCamera *camera() const;
    QVariant mediaObject() const { return QVariant::fromValue<QObject *>(camera()); }

Q_SIGNALS:
    void cameraStatusChanged();
    void cameraStateChanged();
    void captureModeChanged();

private:
    void requestControls();

    QCamera m_camera;

    DeclarativeImageCapture *m_imageCapture;
    DeclarativeVideoRecorder *m_videoRecorder;
    DeclarativeExposure *m_exposure;
    DeclarativeFlash *m_flash;
    DeclarativeFocus *m_focus;
    DeclarativeImageProcessing *m_imageProcessing;
};

class DeclarativeImageCapture : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QSize resolution READ resolution WRITE setResolution NOTIFY resolutionChanged)
public:
    DeclarativeImageCapture(QCamera *camera, QObject *parent = 0);
    ~DeclarativeImageCapture();

    Q_INVOKABLE void capture();

    QSize resolution() const;
    void setResolution(const QSize &resolution);

signals:
    void resolutionChanged();

private:
    QCamera *m_camera;
    QCameraImageCaptureControl *m_captureControl;
    QImageEncoderControl *m_imageEncoderControl;
    QSize m_resolution;
};

class DeclarativeVideoRecorder : public QObject
{
    Q_OBJECT
    Q_PROPERTY(State recorderState READ state NOTIFY stateChanged)
    Q_PROPERTY(QSize resolution READ resolution WRITE setResolution NOTIFY resolutionChanged)
    Q_PROPERTY(qreal frameRate READ frameRate WRITE setFrameRate NOTIFY frameRateChanged)
    Q_PROPERTY(qint64 duration READ duration NOTIFY durationChanged)
    Q_ENUMS(State)
public:
    DeclarativeVideoRecorder(QCamera *camera, QObject *parent = 0);
    ~DeclarativeVideoRecorder();

    enum State
    {
        StoppedState = QMediaRecorder::StoppedState,
        RecordingState = QMediaRecorder::RecordingState,
        PausedState = QMediaRecorder::PausedState
    };

    State state() const;

    Q_INVOKABLE void record();
    Q_INVOKABLE void stop();

    qreal frameRate () const;
    void setFrameRate(qreal rate);

    QSize resolution() const;
    void setResolution(const QSize &resolution);

    qint64 duration() const;

signals:
    void stateChanged();
    void frameRateChanged();
    void resolutionChanged();
    void durationChanged();

private:
    QCamera *m_camera;
    QMediaRecorderControl *m_recorderControl;
    QVideoEncoderControl *m_videoEncoderControl;
};

class DeclarativeImageProcessing : public QObject
{
    Q_OBJECT
    Q_PROPERTY(WhiteBalanceMode whiteBalanceMode READ whiteBalanceMode WRITE setWhiteBalanceMode NOTIFY whiteBalanceModeChanged)
    Q_ENUMS(WhiteBalanceMode)
public:
    DeclarativeImageProcessing(QCamera *camera, QObject *parent = 0);
    ~DeclarativeImageProcessing();

    enum WhiteBalanceMode
    {
        WhiteBalanceAuto = QCameraImageProcessing::WhiteBalanceAuto,
        WhiteBalanceManual = QCameraImageProcessing::WhiteBalanceManual,
        WhiteBalanceSunlight = QCameraImageProcessing::WhiteBalanceSunlight,
        WhiteBalanceCloudy = QCameraImageProcessing::WhiteBalanceCloudy,
        WhiteBalanceShade = QCameraImageProcessing::WhiteBalanceShade,
        WhiteBalanceTungsten = QCameraImageProcessing::WhiteBalanceTungsten,
        WhiteBalanceFluorescent = QCameraImageProcessing::WhiteBalanceFluorescent,
        WhiteBalanceFlash = QCameraImageProcessing::WhiteBalanceFlash,
        WhiteBalanceSunset = QCameraImageProcessing::WhiteBalanceSunset,
        WhiteBalanceVendor = QCameraImageProcessing::WhiteBalanceVendor
    };

    WhiteBalanceMode whiteBalanceMode() const;
    void setWhiteBalanceMode(WhiteBalanceMode mode);

signals:
    void whiteBalanceModeChanged();

private:
    QCamera *m_camera;
    QCameraImageProcessingControl *m_imageProcessingControl;
};


#endif
