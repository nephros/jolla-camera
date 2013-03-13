
#include <QApplication>
#include <QDeclarativeView>
#include <QDeclarativeEngine>
#include <QDeclarativeContext>
#include <QtDeclarative>
#include <QDir>
#include <QTranslator>
#include <QLocale>

#ifdef HAS_BOOSTER
#include <MDeclarativeCache>
#endif

#include "declarativecamera.h"
#include "declarativecameraviewport.h"
#include "declarativeexposure.h"
#include "declarativeflash.h"
#include "declarativefocus.h"
#include "declarativewhitebalance.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
#ifdef HAS_BOOSTER
    QScopedPointer<QApplication> app(MDeclarativeCache::qApplication(argc, argv));
    QScopedPointer<QDeclarativeView> view(MDeclarativeCache::qDeclarativeView());
#else
    QScopedPointer<QApplication> app(new QApplication(argc, argv));
    QScopedPointer<QDeclarativeView> view(new QDeclarativeView);
#endif

    QString translationPath("/usr/share/translations/");

    QTranslator engineeringEnglish;
    engineeringEnglish.load("jolla-camera_eng_en", translationPath);
    qApp->installTranslator(&engineeringEnglish);

    QTranslator translator;
    translator.load(QLocale(), "jolla-camera", "-", translationPath);
    qApp->installTranslator(&translator);

    qmlRegisterType<DeclarativeCamera>("com.jolla.camera", 1, 0, "Camera");
    qmlRegisterType<DeclarativeCameraViewport>("com.jolla.camera", 1, 0, "CameraViewport");
    qmlRegisterUncreatableType<DeclarativeExposure>("com.jolla.camera", 1, 0, "Exposure", QString());
    qmlRegisterUncreatableType<DeclarativeFlash>("com.jolla.camera", 1, 0, "Flash", QString());
    qmlRegisterUncreatableType<DeclarativeFocus>("com.jolla.camera", 1, 0, "Focus", QString());
    qmlRegisterUncreatableType<DeclarativeWhiteBalance>("com.jolla.camera", 1, 0, "WhiteBalance", QString());

    view->setAttribute(Qt::WA_OpaquePaintEvent);
    view->setAttribute(Qt::WA_NoSystemBackground);
    view->setAutoFillBackground(false);
    view->viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    view->viewport()->setAttribute(Qt::WA_NoSystemBackground);
    view->viewport()->setAutoFillBackground(false);

    QString path;
    if (app->arguments().contains("-desktop")) {
        path = app->applicationDirPath() + QDir::separator();
    } else {
        path = QString(QLatin1String(DEPLOYMENT_PATH));
    }

    view->setSource(path + QLatin1String("camera.qml"));

    if (app->arguments().contains("-desktop"))
    {
        view->setFixedSize(480, 854);
        view->rootObject()->setProperty("_desktop", true);
        view->show();
    } else {
        view->showFullScreen();
    }

    return app->exec();
}
