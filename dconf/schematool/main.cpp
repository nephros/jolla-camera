#include <QtGlobal>

# include <QCoreApplication>
# include <QtQml>
# include <QQmlEngine>
# include <QQmlContext>

#include "declarativedconfschema.h"

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    if (argc <  2) {
        qWarning() << "No input schema path supplied";
        return 0;
    } else if (argc <  3) {
        qWarning() << "No output schema path supplied";
        return 0;
    }

    const QString source = QString::fromUtf8(argv[1]);

    qmlRegisterType<DeclarativeDConfSchema>("com.jolla.dconf.schema", 1, 0, "Schema");

    QQmlEngine engine;
    QQmlComponent component(&engine, source);
    QScopedPointer<QObject> object(component.create());
    if (DeclarativeDConfSchema *schema = qobject_cast<DeclarativeDConfSchema *>(object.data())) {
        schema->writeSchema(QString::fromUtf8(argv[2]));
    } else {
        qWarning() << "Failed to create schema from" << source;
        qWarning() << component.errorString();
    }

    return 0;
}
