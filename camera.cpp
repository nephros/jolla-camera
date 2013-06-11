
#include <QDir>
#include <QTranslator>
#include <QLocale>

#include <QGuiApplication>
#include <QQmlEngine>
#include <QQmlContext>
#include <QQuickItem>
#include <QQuickView>
#include <QQmlComponent>

#include <QtDBus/QDBusConnection>
#include <signonuiservice.h>

#ifdef HAS_BOOSTER
#include <MDeclarativeCache>
#endif

#include "declarativecameraextensions.h"
#include "declarativecameralocks.h"
#include "declarativecompassaction.h"
#include "declarativegconfsettings.h"
#include "declarativesettings.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
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

    QTranslator engineeringEnglish;
    engineeringEnglish.load("jolla-camera_eng_en", translationPath);
    qApp->installTranslator(&engineeringEnglish);

    QTranslator translator;
    translator.load(QLocale(), "jolla-camera", "-", translationPath);
    qApp->installTranslator(&translator);

    qmlRegisterType<DeclarativeCameraExtensions>("com.jolla.camera", 1, 0, "CameraExtensions");
    qmlRegisterType<DeclarativeCameraLocks>("com.jolla.camera", 1, 0, "CameraLocks");
    qmlRegisterType<DeclarativeCompassAction>("com.jolla.camera", 1, 0, "CompassAction");
    qmlRegisterType<DeclarativeGConfSettings>("com.jolla.camera", 1, 0, "GConfSettings");
    qmlRegisterType<DeclarativeSettings>("com.jolla.camera", 1, 0, "SettingsBase");
    qmlRegisterUncreatableType<DeclarativeGConf>("com.jolla.camera", 1, 0, "GConf", QString());

    qmlRegisterSingletonType<DeclarativeSettings>("com.jolla.camera", 1, 0, "Settings", DeclarativeSettings::factory);

    SignonUiService *ssoui = new SignonUiService(0, true); // in process
    ssoui->setInProcessServiceName(QLatin1String("com.jolla.camera"));
    ssoui->setInProcessObjectPath(QLatin1String("/JollaCameraSignonUi"));

    QDBusConnection sessionBus = QDBusConnection::sessionBus();
    bool registeredService = sessionBus.registerService(QLatin1String("com.jolla.camera"));
    bool registeredObject = sessionBus.registerObject(QLatin1String("/JollaGallerySignonUi"), ssoui,
            QDBusConnection::ExportAllContents);

    if (!registeredService || !registeredObject) {
        qWarning() << Q_FUNC_INFO << "CRITICAL: unable to register signon ui service:"
                   << QLatin1String("com.jolla.camera") << "at object path:"
                   << QLatin1String("/JollaCameraSignonUi");
    }

    view->rootContext()->setContextProperty("jolla_signon_ui_service", ssoui);

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
