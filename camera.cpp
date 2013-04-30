
#include <QDir>
#include <QTranslator>
#include <QLocale>

#if QT_VERSION >= QT_VERSION_CHECK(5, 0, 0)
# include <QGuiApplication>
# include <QtQml>
# include <QQmlEngine>
# include <QQmlContext>
# include <QQuickItem>
# include <QQuickView>
#else
# include <QApplication>
# include <QDeclarativeView>
# include <QDeclarativeEngine>
# include <QDeclarativeContext>
# include <QtDeclarative>
# include "declarativecamera.h"
# include "declarativecameraviewport.h"
# include "declarativecliparea.h"
# include "declarativeexposure.h"
# include "declarativeflash.h"
# include "declarativefocus.h"
#endif

#ifdef HAS_BOOSTER
#include <MDeclarativeCache>
#endif

#include "declarativecompassaction.h"
#include "declarativesettings.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
#if QT_VERSION >= QT_VERSION_CHECK(5, 0, 0)
#ifdef HAS_BOOSTER
    QScopedPointer<QGuiApplication> app(MDeclarativeCache::qApplication(argc, argv));
    QScopedPointer<QQuickView> view(MDeclarativeCache::qQuickView());
#else
    QScopedPointer<QGuiApplication> app(new QApplication(argc, argv));
    QScopedPointer<QQuickView> view(new QQuickView);
#endif
#else
#ifdef HAS_BOOSTER
    QScopedPointer<QApplication> app(MDeclarativeCache::qApplication(argc, argv));
    QScopedPointer<QDeclarativeView> view(MDeclarativeCache::qDeclarativeView());
#else
    QScopedPointer<QApplication> app(new QApplication(argc, argv));
    QScopedPointer<QDeclarativeView> view(new QDeclarativeView);
#endif
#endif

    QString path(QLatin1String(DEPLOYMENT_PATH));
    QString translationPath("/usr/share/translations/");

    if (app->arguments().contains("-desktop")) {
        path = app->applicationDirPath() + QDir::separator();
        translationPath = path;
    }

    QTranslator engineeringEnglish;
    engineeringEnglish.load("jolla-camera_eng_en", translationPath);
    qApp->installTranslator(&engineeringEnglish);

    QTranslator translator;
    translator.load(QLocale(), "jolla-camera", "-", translationPath);
    qApp->installTranslator(&translator);

    qmlRegisterType<DeclarativeCompassAction>("com.jolla.camera", 1, 0, "CompassAction");

#if QT_VERSION >= QT_VERSION_CHECK(5, 0, 0)
    qmlRegisterSingletonType<DeclarativeSettings>("com.jolla.camera.settings", 1, 0, "Settings", DeclarativeSettings::factory);
#else
    qmlRegisterType<DeclarativeCamera>("com.jolla.camera", 1, 0, "Camera");
    qmlRegisterType<DeclarativeCameraViewport>("com.jolla.camera", 1, 0, "VideoOutput");
    qmlRegisterType<DeclarativeClipArea>("com.jolla.camera", 1, 0, "ClipArea");
    qmlRegisterUncreatableType<DeclarativeImageCapture>("com.jolla.camera", 1, 0, "ImageCapture", QString());
    qmlRegisterUncreatableType<DeclarativeVideoRecorder>("com.jolla.camera", 1, 0, "CameraRecorder", QString());
    qmlRegisterUncreatableType<DeclarativeExposure>("com.jolla.camera", 1, 0, "Exposure", QString());
    qmlRegisterUncreatableType<DeclarativeFlash>("com.jolla.camera", 1, 0, "Flash", QString());
    qmlRegisterUncreatableType<DeclarativeFocus>("com.jolla.camera", 1, 0, "Focus", QString());
    qmlRegisterUncreatableType<DeclarativeImageProcessing>("com.jolla.camera", 1, 0, "CameraImageProcessing", QString());
    qmlRegisterUncreatableType<DeclarativeSettings>("com.jolla.camera.settings", 1, 0, "Settings", QString());

    view->setAttribute(Qt::WA_OpaquePaintEvent);
    view->setAttribute(Qt::WA_NoSystemBackground);
    view->setAutoFillBackground(false);
    view->viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    view->viewport()->setAttribute(Qt::WA_NoSystemBackground);
    view->viewport()->setAutoFillBackground(false);

    DeclarativeSettings settings;
    view->rootContext()->setContextProperty("settings", &settings);
#endif

    view->setSource(path + QLatin1String("camera.qml"));

    if (app->arguments().contains("-desktop"))
    {
#if QT_VERSION >= QT_VERSION_CHECK(5, 0, 0)
        view->resize(480, 854);
#else
        view->setFixedSize(480, 854);
#endif
        view->rootObject()->setProperty("_desktop", true);
        view->show();
    } else {
        view->showFullScreen();
    }

    return app->exec();
}
