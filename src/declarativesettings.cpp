
#include "declarativesettings.h"

#include <QCameraFocus>
#include <QCameraExposure>
#include <QCameraImageProcessing>
#include <QDir>

#if QT_VERSION >= QT_VERSION_CHECK(5, 0, 0)
#include <QStandardPaths>
#else
#include <QDesktopServices>
#endif

namespace {
enum PropertyFlag {
    AspectRatio = 0x01,
    Iso = 0x02,
    WhiteBalance = 0x04,
    FocusDistance = 0x08,
    Flash = 0x10,
    Exposure = 0x20,
    MeteringMode = 0x040
};
}

static const int g_shootingModeProperties[] = {
    /*Auto      */  Iso | WhiteBalance | FocusDistance | Flash | Exposure | Flash | MeteringMode,
    /*Program   */  0,
    /*Macro     */  FocusDistance | Exposure,
    /*Sports    */  Exposure,
    /*Landscape */  FocusDistance | Exposure,
    /*Portait   */  Exposure
};

DeclarativeSettings::DeclarativeSettings(QObject *parent)
    : QObject(parent)
    , m_imageRatio_4_3("/desktop/jolla/camera/imageRatio_4_3")
    , m_imageRatio_16_9("/desktop/jolla/camera/imageRatio_16_9")
    , m_videoRatio_4_3("/desktop/jolla/camera/videoRatio_4_3")
    , m_videoRatio_16_9("/desktop/jolla/camera/videoRatio_16_9")
    , m_shootingMode("/desktop/jolla/camera/shootingMode")
    , m_aspectRatio("/desktop/jolla/camera/aspectRatio")
    , m_iso("/desktop/jolla/camera/iso")
    , m_whiteBalance("/desktop/jolla/camera/whiteBalance")
    , m_focusDistance("/desktop/jolla/camera/focusDistance")
    , m_videoFocus("/desktop/jolla/camera/videoFocus")
    , m_flash("/desktop/jolla/camera/flash")
    , m_exposureCompensation("/desktop/jolla/camera/exposureCompensation")
    , m_meteringMode("/desktop/jolla/camera/meteringMode")
{
    connect(&m_aspectRatio, SIGNAL(valueChanged()), this, SIGNAL(aspectRatioChanged()));
    connect(&m_iso, SIGNAL(valueChanged()), this, SIGNAL(isoChanged()));
    connect(&m_whiteBalance, SIGNAL(valueChanged()), this, SIGNAL(whiteBalanceChanged()));
    connect(&m_focusDistance, SIGNAL(valueChanged()), this, SIGNAL(focusDistanceChanged()));
    connect(&m_videoFocus, SIGNAL(valueChanged()), this, SIGNAL(videoFocusChanged()));
    connect(&m_flash, SIGNAL(valueChanged()), this, SIGNAL(flashChanged()));
    connect(&m_exposureCompensation, SIGNAL(valueChanged()), this, SIGNAL(exposureChanged()));
    connect(&m_meteringMode, SIGNAL(valueChanged()), this, SIGNAL(meteringModeChanged()));

    QDir(photoDirectory()).mkpath(QLatin1String("."));
    QDir(videoDirectory()).mkpath(QLatin1String("."));
}

DeclarativeSettings::~DeclarativeSettings()
{
}

QObject *DeclarativeSettings::factory(QQmlEngine *, QJSEngine *)
{
   return new DeclarativeSettings;
}

QSize DeclarativeSettings::defaultImageResolution(AspectRatioEnum ratio) const
{
    // The default defaults are the typical supported resolutions for a modern
    // webcam and so are reasonably likely to work in most places.
    switch (ratio) {
    case AspectRatio_4_3:
        return m_imageRatio_4_3.value(QSize(640, 480)).value<QSize>();
    case AspectRatio_16_9:
        return m_imageRatio_16_9.value(QSize(1280, 720)).value<QSize>();
    default:
        return QSize();
    }
}

QSize DeclarativeSettings::defaultVideoResolution(AspectRatioEnum ratio) const
{
    switch (ratio) {
    case AspectRatio_4_3:
        return m_imageRatio_4_3.value(QSize(640, 480)).value<QSize>();
    case AspectRatio_16_9:
        return m_imageRatio_16_9.value(QSize(1280, 720)).value<QSize>();
    default:
        return QSize();
    }
}

DeclarativeSettings::ShootingMode DeclarativeSettings::shootingMode() const
{
    return ShootingMode(m_shootingMode.value(Auto).value<int>());
}

void DeclarativeSettings::setShootingMode(ShootingMode mode)
{
    const int previous = shootingMode();
    if (previous != mode) {
        m_shootingMode.set(mode);

        const int changedProperties = g_shootingModeProperties[previous] | g_shootingModeProperties[mode];
        if (changedProperties & Iso)
            emit isoChanged();
        if (changedProperties & WhiteBalance)
            emit whiteBalanceChanged();
        if (changedProperties & FocusDistance)
            emit focusDistanceChanged();
        if (changedProperties & Flash)
            emit flashChanged();
        if (changedProperties & Exposure)
            emit exposureChanged();
        if (changedProperties & MeteringMode)
            emit meteringModeChanged();

        emit shootingModeChanged();
    }
}

DeclarativeSettings::Properties DeclarativeSettings::shootingModeProperties() const
{
    return DeclarativeSettings::Properties(g_shootingModeProperties[shootingMode()]);
}

DeclarativeSettings::AspectRatioEnum DeclarativeSettings::aspectRatio() const
{
    return AspectRatioEnum(m_aspectRatio.value(AspectRatio_16_9).value<int>());
}

void DeclarativeSettings::setAspectRatio(AspectRatioEnum ratio)
{
    m_aspectRatio.set(ratio);
}

int DeclarativeSettings::iso() const
{
    return m_iso.value(0).value<int>();
}

int DeclarativeSettings::effectiveIso() const
{
    switch (shootingMode()) {
    case Auto:
        return 0;
    case Program:
    case Macro:
    case Sports:
    case Landscape:
    case Portrait:
        return iso();
    }
    return iso();
}

void DeclarativeSettings::setIso(int iso)
{
    m_iso.set(iso);
}

int DeclarativeSettings::whiteBalance() const
{
    return m_whiteBalance.value(QCameraImageProcessing::WhiteBalanceAuto).value<int>();
}

int DeclarativeSettings::effectiveWhiteBalance() const
{
    switch (shootingMode()) {
    case Auto:
        return QCameraImageProcessing::WhiteBalanceAuto;
    case Program:
    case Macro:
    case Sports:
    case Landscape:
    case Portrait:
        return whiteBalance();
    }
    return whiteBalance();
}

void DeclarativeSettings::setWhiteBalance(int balance)
{
    m_whiteBalance.set(balance);
}

int DeclarativeSettings::focusDistance() const
{
    return m_focusDistance.value(QCameraFocus::AutoFocus).value<int>();
}

int DeclarativeSettings::effectiveFocusDistance() const
{
    switch (shootingMode()) {
    case Auto:
        return QCameraFocus::AutoFocus;
    case Macro:
        return QCameraFocus::MacroFocus;
    case Landscape:
        return QCameraFocus::InfinityFocus;
    case Program:
    case Sports:
    case Portrait:
        return focusDistance();
    }
    return focusDistance();
}

void DeclarativeSettings::setFocusDistance(int distance)
{
    m_focusDistance.set(distance);
}

int DeclarativeSettings::videoFocus() const
{
    return m_videoFocus.value(QCameraFocus::AutoFocus).value<int>();
}

void DeclarativeSettings::setVideoFocus(int focus)
{
    m_videoFocus.set(focus);
}

int DeclarativeSettings::flash() const
{
    return m_flash.value(1).value<int>();
}

int DeclarativeSettings::effectiveFlash() const
{
    switch (shootingMode()) {
    case Auto:
        return QCameraExposure::FlashAuto;
    case Program:
    case Macro:
    case Sports:
    case Landscape:
    case Portrait:
        return flash();
    }
    return flash();
}

void DeclarativeSettings::setFlash(int flash)
{
    m_flash.set(flash);
}

int DeclarativeSettings::exposureCompensation() const
{
    return m_exposureCompensation.value(0).value<int>();
}

void DeclarativeSettings::setExposureCompensation(int compensation)
{
    m_exposureCompensation.set(compensation);
}

int DeclarativeSettings::exposureMode() const
{
    switch (shootingMode()) {
    case Auto:
        return QCameraExposure::ExposureAuto;
    case Program:
        return QCameraExposure::ExposureManual;
    case Macro:
        return QCameraExposure::ExposureLargeAperture;
    case Sports:
        return QCameraExposure::ExposureSports;
    case Landscape:
        return QCameraExposure::ExposureSmallAperture;
    case Portrait:
        return QCameraExposure::ExposurePortrait;
    default:
        return QCameraExposure::ExposureAuto;
    }
}

int DeclarativeSettings::meteringMode() const
{
    return m_meteringMode.value(QCameraExposure::MeteringMatrix).value<int>();
}

void DeclarativeSettings::setMeteringMode(int mode)
{
    m_meteringMode.set(mode);
}

int DeclarativeSettings::effectiveMeteringMode() const
{
    switch (shootingMode()) {
    case Auto:
        return QCameraExposure::MeteringMatrix;
    case Macro:
    case Landscape:
    case Program:
    case Sports:
    case Portrait:
        return meteringMode();
    }
    return meteringMode();
}

QString DeclarativeSettings::photoDirectory() const
{
#if QT_VERSION >= QT_VERSION_CHECK(5, 0, 0)
    return QStandardPaths::writableLocation(QStandardPaths::PicturesLocation) + QLatin1String("/Camera");
#else
    return QDesktopServices::storageLocation(QDesktopServices::PicturesLocation) + QLatin1String("/Camera");
#endif

}

QString DeclarativeSettings::videoDirectory() const
{
#if QT_VERSION >= QT_VERSION_CHECK(5, 0, 0)
    return QStandardPaths::writableLocation(QStandardPaths::MoviesLocation) + QLatin1String("/Camera");
#else
    return QDesktopServices::storageLocation(QDesktopServices::MoviesLocation) + QLatin1String("/Camera");
#endif
}
