
#include <QDir>
#include <QTranslator>
#include <QLocale>

#include <QGuiApplication>
#include <QQmlEngine>
#include <QQmlContext>
#include <QQuickItem>
#include <QQuickView>
#include <QQmlComponent>

#ifdef HAS_BOOSTER
#include <MDeclarativeCache>
#endif

#include "capturemodel.h"
#include "declarativecameraextensions.h"
#include "declarativecameralocks.h"
#include "declarativecompassaction.h"

#include <gst/gst.h>

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    gst_init(0, 0);
    gst_preset_set_app_dir(JOLLA_CAMERA_GSTREAMER_PRESET_DIRECTORY);

#ifdef HAS_BOOSTER
    QScopedPointer<QGuiApplication> app(MDeclarativeCache::qApplication(argc, argv));
    QScopedPointer<QQuickView> view(MDeclarativeCache::qQuickView());
#else
    QScopedPointer<QGuiApplication> app(new QGuiApplication(argc, argv));
    QScopedPointer<QQuickView> view(new QQuickView);
#endif

    QString path(QLatin1String(DEPLOYMENT_PATH));
    QString translationPath("/usr/share/translations/");

    if (app->arguments().contains("-desktop")) {
        path = app->applicationDirPath() + QDir::separator();
        translationPath = path;
    }

    view->engine()->setBaseUrl(QUrl::fromLocalFile(path));

    //% "Camera"
    QT_TRID_NOOP("jolla-camera-ap-name");
    QTranslator engineeringEnglish;
    engineeringEnglish.load("jolla-camera_eng_en", translationPath);
    qApp->installTranslator(&engineeringEnglish);

    QTranslator translator;
    translator.load(QLocale(), "jolla-camera", "-", translationPath);
    qApp->installTranslator(&translator);

    qmlRegisterType<DeclarativeCameraExtensions>("com.jolla.camera", 1, 0, "CameraExtensions");
    qmlRegisterType<DeclarativeCameraLocks>("com.jolla.camera", 1, 0, "CameraLocks");
    qmlRegisterType<DeclarativeCompassAction>("com.jolla.camera", 1, 0, "CompassAction");
    qmlRegisterType<CaptureModel>("com.jolla.camera", 1, 0, "CaptureModel");

    view->setSource(path + QLatin1String("camera.qml"));

    if (app->arguments().contains("-desktop")) {
        view->resize(480, 854);
        view->rootObject()->setProperty("_desktop", true);
        view->show();
    } else {
        view->showFullScreen();
    }

    return app->exec();
}
