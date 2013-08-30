
#ifndef DECLARATIVEGCONFSCHEMA_H
#define DECLARATIVEGCONFSCHEMA_H

#include <QQmlListProperty>
#include <qqml.h>


QT_BEGIN_NAMESPACE
class QXmlStreamWriter;
QT_END_NAMESPACE

class DeclarativeGConfDescription;

class DeclarativeGConfSchema : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)
    Q_PROPERTY(QString owner READ owner WRITE setOwner NOTIFY ownerChanged)
    Q_PROPERTY(Type type READ type WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(Type listType READ listType WRITE setListType NOTIFY listTypeChanged)
    Q_PROPERTY(Type cdrType READ cdrType WRITE setCdrType NOTIFY cdrTypeChanged)
    Q_PROPERTY(Type carType READ carType WRITE setCarType NOTIFY carTypeChanged)
    Q_PROPERTY(QVariant defaultValue READ defaultValue WRITE setDefaultValue NOTIFY defaultValueChanged)
    Q_PROPERTY(QQmlListProperty<QObject> data READ data CONSTANT)
    Q_ENUMS(Type)
    Q_CLASSINFO("DefaultProperty", "data")
public:
    enum Type {
        Invalid,
        String,
        Int,
        Float,
        Bool,
        List,
        Pair
    };

    DeclarativeGConfSchema(QObject *parent = 0);
    ~DeclarativeGConfSchema();

    QString path() const;
    void setPath(const QString &path);

    QString owner() const;
    void setOwner(const QString &owner);

    Type type() const;
    void setType(Type type);

    Type listType() const;
    void setListType(Type type);

    Type cdrType() const;
    void setCdrType(Type type);

    Type carType() const;
    void setCarType(Type type);

    QVariant defaultValue() const;
    void setDefaultValue(const QVariant &value);

    QQmlListProperty<QObject> data();

    Q_INVOKABLE void writeSchema(const QString &path);

signals:
    void pathChanged();
    void ownerChanged();
    void typeChanged();
    void listTypeChanged();
    void cdrTypeChanged();
    void carTypeChanged();
    void defaultValueChanged();

private:
    static void data_append(QQmlListProperty<QObject> *property, QObject *value);
    static QObject *data_at(QQmlListProperty<QObject> *property, int index);
    static int data_count(QQmlListProperty<QObject> *property);
    static void data_clear(QQmlListProperty<QObject> *property);

    void write(QXmlStreamWriter *writer, const QByteArray &parentPath);

    QVariant m_defaultValue;
    QList<QObject *> m_data;
    QList<DeclarativeGConfSchema *> m_children;
    QList<DeclarativeGConfDescription *> m_descriptions;
    QString m_path;
    QString m_owner;
    DeclarativeGConfSchema *m_parent;
    Type m_type;
    Type m_listType;
    Type m_cdrType;
    Type m_carType;
};

class DeclarativeGConfDescription : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString locale READ locale WRITE setLocale NOTIFY localeChanged)
    Q_PROPERTY(QString brief READ shortDescription READ shortDescription WRITE setShortDescription NOTIFY shortDescriptionChanged)
    Q_PROPERTY(QString extended READ longDescription READ longDescription WRITE setLongDescription NOTIFY longDescriptionChanged)
public:
    DeclarativeGConfDescription(QObject *parent = 0) : QObject(parent) {}

    QString locale() const { return m_locale; }
    void setLocale(const QString &locale) {
        if (m_locale != locale) { m_locale = locale; emit localeChanged(); } }

    QString shortDescription() const { return m_short; }
    void setShortDescription(const QString &description) {
        if (m_short != description) { m_short = description; emit shortDescriptionChanged(); } }

    QString longDescription() const { return m_long; }
    void setLongDescription(const QString &description) {
        if (m_long != description) { m_long = description; emit longDescriptionChanged(); } }

signals:
    void localeChanged();
    void shortDescriptionChanged();
    void longDescriptionChanged();

private:
    QString m_locale;
    QString m_short;
    QString m_long;
};

#endif
