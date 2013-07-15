
#include <qqml.h>
#include <QQmlExtensionPlugin>

#include "declarativecompassaction.h"

class Plugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "com.jolla.camera")
public:
    void registerTypes(const char *)
    {
        qmlRegisterType<DeclarativeCompassAction>("com.jolla.camera", 1, 0, "CompassAction");
    }
};

#include "camera.moc"
