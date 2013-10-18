
#include <qqml.h>
#include <QQmlExtensionPlugin>

#include "capturemodel.h"

class Plugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "com.jolla.camera")
public:
    void registerTypes(const char *)
    {
        qmlRegisterType<CaptureModel>("com.jolla.camera", 1, 0, "CaptureModel");
    }
};

#include "camera.moc"
