
#include "declarativedconfschema.h"

# include <QQmlInfo>

#include <QFile>
#include <QMetaObject>
#include <QSize>
#include <QStringList>



DeclarativeDConfSchema::DeclarativeDConfSchema(QObject *parent)
    : QObject(parent)
    , m_parent(0)
{
}

DeclarativeDConfSchema::~DeclarativeDConfSchema()
{
}

QString DeclarativeDConfSchema::path() const
{
    return m_path;
}

void DeclarativeDConfSchema::setPath(const QString &path)
{
    if (m_path != path) {
        m_path = path;
        emit pathChanged();
    }
}

QQmlListProperty<QObject> DeclarativeDConfSchema::data()
{
    return QQmlListProperty<QObject>(this, 0, data_append, data_count, data_at, data_clear);
}

void DeclarativeDConfSchema::data_append(QQmlListProperty<QObject> *property, QObject *value)
{
    DeclarativeDConfSchema *schema = static_cast<DeclarativeDConfSchema *>(property->object);
    schema->m_data.append(value);
    if (DeclarativeDConfSchema *child = qobject_cast<DeclarativeDConfSchema *>(value)) {
        schema->m_children.append(child);
        child->m_parent = schema;
    }
}

QObject *DeclarativeDConfSchema::data_at(QQmlListProperty<QObject> *property, int index)
{
    return static_cast<DeclarativeDConfSchema *>(property->object)->m_data.at(index);
}

int DeclarativeDConfSchema::data_count(QQmlListProperty<QObject> *property)
{
    return static_cast<DeclarativeDConfSchema *>(property->object)->m_data.count();
}

void DeclarativeDConfSchema::data_clear(QQmlListProperty<QObject> *)
{
}


void DeclarativeDConfSchema::writeSchema(const QString &path)
{
    QByteArray parentPath;
    for (DeclarativeDConfSchema *parent = m_path.startsWith(QLatin1Char('/')) ? m_parent : 0;
            parent && !parentPath.startsWith('/');
            parent = parent->m_parent) {
        parentPath = parent->m_path.toUtf8() + '/' + parentPath;
    }

    if (!m_path.startsWith(QLatin1Char('/')) && !parentPath.startsWith('/')) {
        qmlInfo(this) << "A schema path must start with /";
        return;
    }

    QFile file(path);
    if (!file.open(QIODevice::WriteOnly)) {
        qmlInfo(this) << "Cannot open " << path << " for write";
        qmlInfo(this) << file.errorString();
        return;
    }

    write(&file, parentPath);

    file.close();
}

template <int N>
static void writeData(QFile *file, const char (&data)[N])
{
    file->write(data, N - 1);
}

static void writeData(QFile *file, const QByteArray &data)
{
    file->write(data);
}

static QString quote(const QString &string)
{
    return QLatin1Char('\'') + string + QLatin1Char('\'');
}

static QString toString(const QVariant &variant)
{
    QStringList stringList;

    switch (variant.type()) {
    case QVariant::Bool:
    case QVariant::Int:
    case QVariant::Double:
        return variant.toString();
    case QVariant::Size: {
        QSize size = variant.toSize();
        return QString(QStringLiteral("(%1,%2)")).arg(size.width()).arg(size.height());
    }
    case QVariant::SizeF: {
        QSizeF size = variant.toSizeF();
        return QString(QStringLiteral("(%1,%2)")).arg(size.width()).arg(size.height());
    }
    case QVariant::StringList:
        foreach (const QString &string, variant.toString()) {
            stringList.append(quote(string));
        }
        break;
    default:
        if (variant.userType() == qMetaTypeId<QVariantList>()) {
            const QVariantList list = variant.value<QVariantList>();
            for (int i = 0; i < list.count(); ++i) {
                stringList.append(toString(list.at(i)));
            }
        } else {
            return quote(variant.toString());
        }
        break;
    }

    return QLatin1Char('[') + stringList.join(QLatin1String(", ")) + QLatin1Char(']');
}

void DeclarativeDConfSchema::write(QFile *file, const QByteArray &parentPath)
{
    QByteArray absolutePath;

    if (m_path.isEmpty()) {
        qmlInfo(this) << "Empty schema path";
        return;
    } else if (m_path.startsWith(QLatin1Char('/'))) {
        absolutePath = m_path.mid(1).toUtf8();
    } else {
        absolutePath = parentPath + "/" + m_path.toUtf8();
    }

    writeData(file, "[");
    writeData(file, absolutePath);
    writeData(file, "]\n");

    const QMetaObject * const meta = metaObject();
    for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
        const QMetaProperty property = meta->property(i);
        const QByteArray string = toString(property.read(this)).toUtf8();
        if (!string.isEmpty()) {
            writeData(file, property.name());
            writeData(file, "=");
            writeData(file, string);
            writeData(file, "\n");
        }
    }

    writeData(file, "\n");

    for (int i = 0; i < m_children.count(); ++i) {
        m_children.at(i)->write(file, absolutePath);
    }
}

