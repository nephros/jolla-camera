
#include "declarativegconfschema.h"

# include <QQmlInfo>

#include <QFile>
#include <QSize>
#include <QStringList>
#include <QXmlStreamWriter>


DeclarativeGConfSchema::DeclarativeGConfSchema(QObject *parent)
    : QObject(parent)
    , m_parent(0)
    , m_type(Invalid)
    , m_listType(Invalid)
    , m_cdrType(Invalid)
    , m_carType(Invalid)
{
}

DeclarativeGConfSchema::~DeclarativeGConfSchema()
{
}

QString DeclarativeGConfSchema::path() const
{
    return m_path;
}

void DeclarativeGConfSchema::setPath(const QString &path)
{
    if (m_path != path) {
        m_path = path;
        emit pathChanged();
    }
}

QString DeclarativeGConfSchema::owner() const
{
    return m_owner;
}

void DeclarativeGConfSchema::setOwner(const QString &owner)
{
    if (m_owner != owner) {
        m_owner = owner;
        emit ownerChanged();
    }
}

DeclarativeGConfSchema::Type DeclarativeGConfSchema::type() const
{
    return m_type;
}

void DeclarativeGConfSchema::setType(Type type)
{
    if (m_type != type) {
        m_type = type;
        emit typeChanged();
    }
}

DeclarativeGConfSchema::Type DeclarativeGConfSchema::listType() const
{
    return m_listType;
}

void DeclarativeGConfSchema::setListType(Type type)
{
    if (m_listType != type) {
        m_listType = type;
        emit typeChanged();
    }
}

DeclarativeGConfSchema::Type DeclarativeGConfSchema::cdrType() const
{
    return m_cdrType;
}

void DeclarativeGConfSchema::setCdrType(Type type)
{
    if (m_cdrType != type) {
        m_cdrType = type;
        emit typeChanged();
    }
}

DeclarativeGConfSchema::Type DeclarativeGConfSchema::carType() const
{
    return m_carType;
}

void DeclarativeGConfSchema::setCarType(Type type)
{
    if (m_carType != type) {
        m_carType = type;
        emit typeChanged();
    }
}

QVariant DeclarativeGConfSchema::defaultValue() const
{
    return m_defaultValue;
}

void DeclarativeGConfSchema::setDefaultValue(const QVariant &value)
{
    if (m_defaultValue != value) {
        m_defaultValue = value;
        emit defaultValueChanged();
    }
}

QQmlListProperty<QObject> DeclarativeGConfSchema::data()
{
    return QQmlListProperty<QObject>(this, 0, data_append, data_count, data_at, data_clear);
}

void DeclarativeGConfSchema::data_append(QQmlListProperty<QObject> *property, QObject *value)
{
    DeclarativeGConfSchema *schema = static_cast<DeclarativeGConfSchema *>(property->object);
    schema->m_data.append(value);
    if (DeclarativeGConfSchema *child = qobject_cast<DeclarativeGConfSchema *>(value)) {
        schema->m_children.append(child);
        child->m_parent = schema;
    } else if (DeclarativeGConfDescription *description = qobject_cast<DeclarativeGConfDescription *>(value)) {
        schema->m_descriptions.append(description);
    }
}

QObject *DeclarativeGConfSchema::data_at(QQmlListProperty<QObject> *property, int index)
{
    return static_cast<DeclarativeGConfSchema *>(property->object)->m_data.at(index);
}

int DeclarativeGConfSchema::data_count(QQmlListProperty<QObject> *property)
{
    return static_cast<DeclarativeGConfSchema *>(property->object)->m_data.count();
}

void DeclarativeGConfSchema::data_clear(QQmlListProperty<QObject> *)
{
}


void DeclarativeGConfSchema::writeSchema(const QString &path)
{
    QByteArray parentPath;
    for (DeclarativeGConfSchema *parent = m_path.startsWith(QLatin1Char('/')) ? m_parent : 0;
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

    QXmlStreamWriter writer(&file);
    writer.setAutoFormatting(true);
    writer.writeStartDocument();
    writer.writeStartElement(QLatin1String("gconfschemafile"));
    writer.writeStartElement(QLatin1String("schemalist"));

    write(&writer, parentPath);

    writer.writeEndElement();
    writer.writeEndElement();
    writer.writeEndDocument();

    file.close();
}

static void writeTypeElement(
        QXmlStreamWriter *writer, const char *name, DeclarativeGConfSchema::Type type)
{
    switch (type) {
    case DeclarativeGConfSchema::String:
        writer->writeTextElement(QLatin1String(name), "string");
        break;
    case DeclarativeGConfSchema::Int:
        writer->writeTextElement(QLatin1String(name), "int");
        break;
    case DeclarativeGConfSchema::Float:
        writer->writeTextElement(QLatin1String(name), "float");
        break;
    case DeclarativeGConfSchema::Bool:
        writer->writeTextElement(QLatin1String(name), "bool");
        break;
    case DeclarativeGConfSchema::List:
        writer->writeTextElement(QLatin1String(name), "list");
        break;
    case DeclarativeGConfSchema::Pair:
        writer->writeTextElement(QLatin1String(name), "pair");
        break;
    default:
        break;
    }
}

static QString toString(const QVariant &variant)
{
    QStringList stringList;

    if (variant.type() == QVariant::StringList) {
        stringList = variant.toStringList();
    } else if (variant.userType() == qMetaTypeId<QVariantList>()) {
        const QVariantList list = variant.value<QVariantList>();
        for (int i = 0; i < list.count(); ++i) {
            stringList.append(list.at(i).toString());
        }
    } else if (variant.type() == QVariant::Size) {
        QSize size = variant.toSize();
        return QString(QStringLiteral("(%1,%2)")).arg(size.width()).arg(size.height());
    } else if (variant.type() == QVariant::SizeF) {
        QSizeF size = variant.toSizeF();
        return QString(QStringLiteral("(%1,%2)")).arg(size.width()).arg(size.height());
    } else {
        return variant.toString();
    }
    return stringList.join(QLatin1String(", "));
}

void DeclarativeGConfSchema::write(QXmlStreamWriter *writer, const QByteArray &parentPath)
{
    QByteArray key;

    if (m_path.isEmpty()) {
        qmlInfo(this) << "Empty schema path";
        return;
    } else if (m_path.startsWith(QLatin1Char('/'))) {
        key = m_path.toUtf8();
    } else if (parentPath.startsWith('/')) {
        key = parentPath + "/" + m_path.toUtf8();
    } else {
        // unreachable.
        return;
    }

    if (m_type != Invalid) {
        writer->writeStartElement(QLatin1String("schema"));
        writer->writeTextElement(QLatin1String("key"), QLatin1String("/schemas") +key);
        writer->writeTextElement(QLatin1String("applyto"), key);
        writer->writeTextElement(QLatin1String("owner"), m_owner);
        writeTypeElement(writer, "type", m_type);
        if (m_type == List) {
            writeTypeElement(writer, "list_type", m_listType);
        } else if (m_type == Pair) {
            writeTypeElement(writer, "car_type", m_carType);
            writeTypeElement(writer, "cdr_type", m_cdrType);
        }
        if (m_defaultValue.isValid()) {
            writer->writeTextElement(QLatin1String("default"), toString(m_defaultValue));
        }
        for (int i = 0; i < m_descriptions.count(); ++i) {
            DeclarativeGConfDescription *description = m_descriptions.at(i);
            writer->writeStartElement(QLatin1String("locale"));
            writer->writeAttribute(QLatin1String("name"), description->locale());
            if (!description->shortDescription().isEmpty()) {
                writer->writeTextElement(QLatin1String("short"), description->shortDescription());
            }
            if (!description->longDescription().isEmpty()) {
                writer->writeTextElement(QLatin1String("long"), description->longDescription());
            }
            writer->writeEndElement();
        }
        writer->writeEndElement();
    }

    for (int i = 0; i < m_children.count(); ++i) {
        m_children.at(i)->write(writer, key);
    }
}

