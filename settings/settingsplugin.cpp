
#include <QQmlExtensionPlugin>
#include <QTranslator>
#include <QGuiApplication>
#include <QQmlEngine>
#include <QLocale>

#include <qqml.h>

#include "declarativegconfsettings.h"
#include "declarativesettings.h"

// using custom translator so it gets properly removed from qApp when engine is deleted
class AppTranslator: public QTranslator
{
public:
    AppTranslator(QObject *parent)
        : QTranslator(parent)
    {
        qApp->installTranslator(this);
    }

    virtual ~AppTranslator()
    {
        qApp->removeTranslator(this);
    }
};


class ContactsSettingsPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "com.jolla.camera.settings")

public:

    void initializeEngine(QQmlEngine *engine, const char *uri)
    {
        Q_UNUSED(uri)
        Q_UNUSED(engine)
        Q_ASSERT(QLatin1String(uri) == QLatin1String("com.jolla.camera.settings"));

        AppTranslator *engineeringEnglish = new AppTranslator(engine);
        AppTranslator *translator = new AppTranslator(engine);
        engineeringEnglish->load("jolla-camera_settings_eng_en", "/usr/share/translations");
        translator->load(QLocale(), "jolla-camera_settings", "-", "/usr/share/translations");
    }

    virtual void registerTypes(const char *uri)
    {
        Q_UNUSED(uri)
        Q_ASSERT(QLatin1String(uri) == QLatin1String("com.jolla.camera.settings"));

        qmlRegisterType<DeclarativeGConfSettings>("com.jolla.camera.settings", 1, 0, "GConfSettings");
        qmlRegisterType<DeclarativeSettings>("com.jolla.camera.settings", 1, 0, "SettingsBase");
        qmlRegisterSingletonType<DeclarativeSettings>("com.jolla.camera.settings", 1, 0, "Settings", DeclarativeSettings::factory);

    }
};

#include "settingsplugin.moc"
