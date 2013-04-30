
#include <qdeclarative.h>
#include <QDeclarativeExtensionPlugin>

#include "declarativecompassaction.h"
#include "declarativecliparea.h"

class Plugin : public QDeclarativeExtensionPlugin
{
    Q_OBJECT
public:
    void registerTypes(const char *)
    {
        qmlRegisterType<DeclarativeCompassAction>("com.jolla.camera", 1, 0, "CompassAction");
        qmlRegisterType<DeclarativeClipArea>("com.jolla.camera", 1, 0, "ClipArea");
    }
};

Q_EXPORT_PLUGIN2(jollacameraplugin, Plugin);

#include "camera.moc"
