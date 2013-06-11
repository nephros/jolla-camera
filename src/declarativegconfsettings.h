
#ifndef DECLARATIVEGCONFSETTINGS_H
#define DECALRATIVEGCONFSETTGINS_H

#include <QQmlParserStatus>
#include <QQmlListProperty>
#include <qqml.h>

#include <QVector>

#ifndef GCONF_DISABLED
#include <gconf/gconf-value.h>
#include <gconf/gconf-client.h>
#endif

/*!
    This is a prototype, if it works as intended it should get promoted to nemo somewhere.

    GConfSettings {
        id: settings
        path: "/desktop/jolla/camera"
        property string shootingMode: "automatic"
        GConfSettings {
            path: settings.shootingMode
            property int iso: 0
            property int whiteBalance: CameraImageProcessing.WhiteBalanceAutomatic
        }
    }
*/

class DeclarativeGConfSettings : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)
    Q_PROPERTY(QQmlListProperty<QObject> data READ data CONSTANT)
    Q_INTERFACES(QQmlParserStatus)
    Q_CLASSINFO("DefaultProperty", "data")
public:
    DeclarativeGConfSettings(QObject *parent = 0);
    ~DeclarativeGConfSettings();

    void classBegin();
    void componentComplete();

    QString path() const;
    void setPath(const QString &path);

    QQmlListProperty<QObject> data();

signals:
    void pathChanged();

private slots:
    void propertyChanged();

private:
    static void data_append(QQmlListProperty<QObject> *property, QObject *value);
    static QObject *data_at(QQmlListProperty<QObject> *property, int index);
    static int data_count(QQmlListProperty<QObject> *property);
    static void data_clear(QQmlListProperty<QObject> *property);

    void resolveProperties(const QByteArray &parentPath);

    QByteArray m_absolutePath;
    QString m_path;
    QList<QObject *> m_data;
    QList<DeclarativeGConfSettings *> m_children;
    DeclarativeGConfSettings *m_parent;

#ifndef GCONF_DISABLED
    void cancelNotifications();
    void readValue(const QMetaProperty &property, GConfValue *value);

    static void notify(GConfClient *client, guint cnxn_id, GConfEntry *entry, gpointer user_data);

    struct Property { int propertyIndex; guint notifyId; };
    QVector<Property> m_properties;
    GConfClient *m_client;
#endif

    int m_readPropertyIndex;
};

// This should be a singleton, but an attached object will do.
class DeclarativeGConf : public QObject
{
    Q_OBJECT
public:
    DeclarativeGConf(QObject *parent = 0);
    ~DeclarativeGConf();

    static DeclarativeGConf *qmlAttachedProperties(QObject *);

    Q_INVOKABLE QVariant read(const QString &key);
    Q_INVOKABLE void write(const QString &key, const QVariant &value);

private:
#ifndef GCONF_DISABLED
    GConfClient *m_client;
#endif
};

QML_DECLARE_TYPE(DeclarativeGConf)
QML_DECLARE_TYPEINFO(DeclarativeGConf, QML_HAS_ATTACHED_PROPERTIES)

#endif
