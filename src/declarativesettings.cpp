
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

DeclarativeSettings::DeclarativeSettings(QObject *parent)
    : QObject(parent)
    , m_imageRatio_4_3("/desktop/jolla/camera/imageRatio_4_3")
    , m_imageRatio_16_9("/desktop/jolla/camera/imageRatio_16_9")
    , m_videoRatio_4_3("/desktop/jolla/camera/videoRatio_4_3")
    , m_videoRatio_16_9("/desktop/jolla/camera/videoRatio_16_9")
{
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
