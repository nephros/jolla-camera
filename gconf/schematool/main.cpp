#include <QtGlobal>

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
# include "declarativeexposure.h"
# include "declarativeflash.h"
# include "declarativefocus.h"
#endif

#include "declarativegconfschema.h"
#include "declarativesettings.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    if (argc <  2) {
        qWarning() << "No input schema path supplied";
        return 0;
    } else if (argc <  3) {
        qWarning() << "No output schema path supplied";
        return 0;
    }

    const QString source = QString::fromUtf8(argv[1]);

#if QT_VERSION >= QT_VERSION_CHECK(5, 0, 0)
    qmlRegisterSingletonType<DeclarativeSettings>("com.jolla.camera", 1, 0, "Settings", DeclarativeSettings::factory);
#else
    qmlRegisterType<DeclarativeCamera>("com.jolla.camera", 1, 0, "Camera");
    qmlRegisterType<DeclarativeCameraViewport>("com.jolla.camera", 1, 0, "VideoOutput");
    qmlRegisterUncreatableType<DeclarativeImageCapture>("com.jolla.camera", 1, 0, "ImageCapture", QString());
    qmlRegisterUncreatableType<DeclarativeVideoRecorder>("com.jolla.camera", 1, 0, "CameraRecorder", QString());
    qmlRegisterUncreatableType<DeclarativeExposure>("com.jolla.camera", 1, 0, "Exposure", QString());
    qmlRegisterUncreatableType<DeclarativeFlash>("com.jolla.camera", 1, 0, "Flash", QString());
    qmlRegisterUncreatableType<DeclarativeFocus>("com.jolla.camera", 1, 0, "Focus", QString());
    qmlRegisterUncreatableType<DeclarativeImageProcessing>("com.jolla.camera", 1, 0, "CameraImageProcessing", QString());
    qmlRegisterUncreatableType<DeclarativeSettings>("com.jolla.camera", 1, 0, "Settings", QString());
#endif

    qmlRegisterType<DeclarativeGConfSchema>("com.jolla.gconf.schema", 1, 0, "GConfSchema");
    qmlRegisterType<DeclarativeGConfDescription>("com.jolla.gconf.schema", 1, 0, "GConfDescription");

    QDeclarativeEngine engine;
    QDeclarativeComponent component(&engine, source);
    QScopedPointer<QObject> object(component.create());
    if (DeclarativeGConfSchema *schema = qobject_cast<DeclarativeGConfSchema *>(object.data())) {
        schema->writeSchema(QString::fromUtf8(argv[2]));
    } else {
        qWarning() << "Failed to create schema from" << source;
        qWarning() << component.errorString();
    }

    return 0;
}
