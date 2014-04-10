
#ifndef DECLARATIVEDCONFSCHEMA_H
#define DECLARATIVEDCONFSCHEMA_H

#include <QQmlListProperty>
#include <qqml.h>


QT_BEGIN_NAMESPACE
class QFile;
QT_END_NAMESPACE

class DeclarativeDConfSchema : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)
    Q_PROPERTY(QQmlListProperty<QObject> data READ data CONSTANT)
    Q_ENUMS(Type)
    Q_CLASSINFO("DefaultProperty", "data")
public:
    DeclarativeDConfSchema(QObject *parent = 0);
    ~DeclarativeDConfSchema();

    QString path() const;
    void setPath(const QString &path);

    QVariant defaultValue() const;
    void setDefaultValue(const QVariant &value);

    QQmlListProperty<QObject> data();

    Q_INVOKABLE void writeSchema(const QString &path);

signals:
    void pathChanged();
    void defaultValueChanged();

private:
    static void data_append(QQmlListProperty<QObject> *property, QObject *value);
    static QObject *data_at(QQmlListProperty<QObject> *property, int index);
    static int data_count(QQmlListProperty<QObject> *property);
    static void data_clear(QQmlListProperty<QObject> *property);

    void write(QFile *writer, const QByteArray &parentPath);

    QList<QObject *> m_data;
    QList<DeclarativeDConfSchema *> m_children;
    QString m_path;
    DeclarativeDConfSchema *m_parent;

};

#endif
