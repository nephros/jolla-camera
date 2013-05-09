
#include "declarativegconfsettings.h"

#include <QDeclarativeInfo>
#include <QMetaProperty>
#include <QStringList>

DeclarativeGConfSettings::DeclarativeGConfSettings(QObject *parent)
    : QObject(parent)
    , m_parent(0)
#ifndef GCONF_DISABLED
    , m_client(0)
#endif
    , m_readPropertyIndex(-1)
{
}

DeclarativeGConfSettings::~DeclarativeGConfSettings()
{
#ifndef GCONF_DISABLED
    if (m_client) {
        if (!m_parent && !m_absolutePath.isEmpty()) {
            gconf_client_remove_dir(m_client, m_absolutePath.constData(), 0);
        }

        cancelNotifications();

        g_object_unref(m_client);
    }
#endif
}

void DeclarativeGConfSettings::classBegin()
{
    const int propertyChangedIndex = staticMetaObject.indexOfMethod("propertyChanged()");
    Q_ASSERT(propertyChangedIndex != -1);

    const QMetaObject * const metaObject = this->metaObject();
    if (metaObject == &staticMetaObject)
        return;

    for (int i = metaObject->propertyOffset(); i < metaObject->propertyCount(); ++i) {
        const QMetaProperty property = metaObject->property(i);

        if (property.hasNotifySignal()) {
            QMetaObject::connect(this, property.notifySignalIndex(), this, propertyChangedIndex);
        }
    }
}

void DeclarativeGConfSettings::componentComplete()
{
#ifndef GCONF_DISABLED
    m_client = gconf_client_get_default();

    if (!m_path.isEmpty() && m_path.startsWith(QLatin1Char('/'))) {
        if (!m_parent) {
            GError *error = 0;
            gconf_client_add_dir(
                        m_client,
                        m_path.toUtf8().constData(),
                        GCONF_CLIENT_PRELOAD_RECURSIVE,
                        &error);
            if (error) {
                qmlInfo(this) << "Failed to enable notifications for path " << m_path;
                qmlInfo(this) << error->message;
                g_error_free(error);
            }
        }
        resolveProperties(QByteArray());
    } else if (m_parent && !m_absolutePath.isEmpty()) {
        resolveProperties(m_parent->m_absolutePath);
    }
#endif
}

QString DeclarativeGConfSettings::path() const
{
    return m_path;
}

void DeclarativeGConfSettings::setPath(const QString &path)
{
    if (m_path != path) {
        m_path = path;
        emit pathChanged();

#ifndef GCONF_DISABLED
        if (m_client && !m_absolutePath.isEmpty()) {
            if (!m_parent) {
                gconf_client_remove_dir(m_client, m_absolutePath.constData(), 0);
            }

            if (m_path.isEmpty()) {
                m_absolutePath = QByteArray();
                cancelNotifications();
            } else if (m_parent && !m_path.startsWith(QLatin1Char('/'))) {
                resolveProperties(m_parent->m_absolutePath);
            } else {
                if (!m_parent) {
                    GError *error = 0;
                    gconf_client_add_dir(
                                m_client,
                                m_path.toUtf8().constData(),
                                GCONF_CLIENT_PRELOAD_RECURSIVE,
                                &error);
                    if (error) {
                        qmlInfo(this) << "Failed to register listener for path " << m_path;
                        qmlInfo(this) << error->message;
                        g_error_free(error);
                    }
                }
                resolveProperties(QByteArray());
            }
        }
#endif
    }
}

QDeclarativeListProperty<QObject> DeclarativeGConfSettings::data()
{
    return QDeclarativeListProperty<QObject>(this, 0, data_append, data_count, data_at);
}

void DeclarativeGConfSettings::data_append(QDeclarativeListProperty<QObject> *property, QObject *value)
{
    DeclarativeGConfSettings *settings = static_cast<DeclarativeGConfSettings *>(property->object);
    settings->m_data.append(value);
    if (DeclarativeGConfSettings *child = qobject_cast<DeclarativeGConfSettings *>(value)) {
        settings->m_children.append(child);
        child->m_parent = settings;
    }
}

QObject *DeclarativeGConfSettings::data_at(QDeclarativeListProperty<QObject> *property, int index)
{
    return static_cast<DeclarativeGConfSettings *>(property->object)->m_data.at(index);
}

int DeclarativeGConfSettings::data_count(QDeclarativeListProperty<QObject> *property)
{
    return static_cast<DeclarativeGConfSettings *>(property->object)->m_data.count();
}

#ifndef GCONF_DISABLED

template <typename T> GConfValue *toGConfValue(const QVariant &) { return 0; }

template <> GConfValue *toGConfValue<QString>(const QVariant &variant)
{
    GConfValue *value = gconf_value_new(GCONF_VALUE_STRING);
    gconf_value_set_string(value, variant.toString().toUtf8());
    return value;
}

template <> GConfValue *toGConfValue<int>(const QVariant &variant)
{
    GConfValue *value = gconf_value_new(GCONF_VALUE_INT);
    gconf_value_set_int(value, variant.toInt());
    return value;
}

template <> GConfValue *toGConfValue<double>(const QVariant &variant)
{
    GConfValue *value = gconf_value_new(GCONF_VALUE_FLOAT);
    gconf_value_set_float(value, variant.toDouble());
    return value;
}

template <> GConfValue *toGConfValue<bool>(const QVariant &variant)
{
    GConfValue *value = gconf_value_new(GCONF_VALUE_BOOL);
    gconf_value_set_bool(value, variant.toBool());
    return value;
}

template <> GConfValue *toGConfValue<QStringList>(const QVariant &variant)
{
    const QStringList stringList = variant.value<QStringList>();

    GSList *list = 0;
    for (int i = 0; i < stringList.count(); ++i) {
        GConfValue *value = gconf_value_new(GCONF_VALUE_STRING);
        gconf_value_set_string(value, stringList.at(i).toUtf8());
        list = g_slist_prepend(list, value);
    }

    GConfValue *value = gconf_value_new(GCONF_VALUE_LIST);
    gconf_value_set_list_type(value, GCONF_VALUE_STRING);
    gconf_value_set_list_nocopy(value, g_slist_reverse(list));

    return value;
}

template <typename T> GConfValue *toGConfList(const QVariantList &variantList, GConfValueType type)
{
    GSList *list = 0;
    for (int i = 0; i < variantList.count(); ++i) {
        list = g_slist_prepend(list, toGConfValue<T>(variantList.at(i)));
    }

    GConfValue *value = gconf_value_new(GCONF_VALUE_LIST);
    gconf_value_set_list_type(value, type);
    gconf_value_set_list_nocopy(value, g_slist_reverse(list));

    return value;
}

template <> GConfValue *toGConfValue<QVariant>(const QVariant &variant)
{
    switch (variant.type()) {
    case QVariant::Invalid:    return 0;
    case QVariant::String:     return toGConfValue<QString>(variant);
    case QVariant::Int:        return toGConfValue<int>(variant);
    case QVariant::UInt:       return toGConfValue<int>(variant);
    case QVariant::Double:     return toGConfValue<double>(variant);
    case QVariant::Bool:       return toGConfValue<bool>(variant);
    case QVariant::StringList: return toGConfValue<QStringList>(variant);
    default:
        if (variant.userType() == qMetaTypeId<QVariantList>()) {
            QVariantList list = variant.value<QVariantList>();
            if (list.isEmpty()) {
                // ### The magic kind of fails here, how do you deduce the type of an empty
                // list?
                GConfValue *value = gconf_value_new(GCONF_VALUE_LIST);
                gconf_value_set_list_type(value, GCONF_VALUE_INT);
                return value;
            } else {
                switch (list.first().type()) {
                case QVariant::Invalid:    return 0;
                case QVariant::String:     return toGConfList<QString>(list, GCONF_VALUE_STRING);
                case QVariant::Int:        return toGConfList<int>(list, GCONF_VALUE_INT);
                case QVariant::UInt:       return toGConfList<int>(list, GCONF_VALUE_INT);
                case QVariant::Double:     return toGConfList<double>(list, GCONF_VALUE_FLOAT);
                case QVariant::Bool:       return toGConfList<bool>(list, GCONF_VALUE_BOOL);
                default:
                    if (variant.userType() == qMetaTypeId<float>()) {
                        return toGConfList<double>(list, GCONF_VALUE_FLOAT);
                    } else if (variant.canConvert<int>()) {
                        return toGConfList<int>(list, GCONF_VALUE_INT);
                    }
                }
            }
        } else if (variant.userType() == qMetaTypeId<float>()) {
            return toGConfValue<double>(variant);
        } else if (variant.canConvert<int>()) {
            return toGConfValue<int>(variant);
        }
        return 0;
    }
}

#endif

void DeclarativeGConfSettings::propertyChanged()
{
#ifndef GCONF_DISABLED
    if (m_absolutePath.isEmpty())
        return;

    const int notifyIndex = senderSignalIndex();
    const QMetaObject * const metaObject = this->metaObject();

    for (int i = metaObject->propertyOffset(); i < metaObject->propertyCount(); ++i) {
        const QMetaProperty property = metaObject->property(i);
        if (i != m_readPropertyIndex && property.notifySignalIndex() == notifyIndex) {
            const QByteArray key = m_absolutePath + property.name();
            const QVariant variant = property.read(this);

            GError *error = 0;
            if (GConfValue *value = toGConfValue<QVariant>(variant)) {
                gconf_client_set(m_client, key.constData(), value, &error);
                gconf_value_free(value);
            } else if (variant.type() == QVariant::Invalid) {
                gconf_client_unset(m_client, key.constData(), &error);
            }

            if (error) {
                qmlInfo(this) << "Failed to write value for " << key << variant;
                qmlInfo(this) << error->message;
                g_error_free(error);
            }
        }
    }
#endif
}

void DeclarativeGConfSettings::resolveProperties(const QByteArray &parentPath)
{
#ifndef GCONF_DISABLED
    cancelNotifications();

    m_absolutePath = parentPath + m_path.toUtf8() + '/';

    const QMetaObject * const metaObject = this->metaObject();
    if (metaObject == &staticMetaObject)
        return;

    for (int i = metaObject->propertyOffset(); i < metaObject->propertyCount(); ++i) {
        GError *error = 0;
        const QMetaProperty property = metaObject->property(i);
        const QByteArray key = m_absolutePath + property.name();

        GConfValue *value = gconf_client_get(m_client, key.constData(), &error);
        if (error) {
            qmlInfo(this) << "Failed to get value for " << key;
            qmlInfo(this) << error->message;
            g_error_free(error);
            error = 0;
        } else if (value) {
            m_readPropertyIndex = i;
            readValue(property, value);
            m_readPropertyIndex = -1;
            gconf_value_free(value);
        }

        Property p = { i, gconf_client_notify_add(m_client, key.constData(), notify, this, 0, &error) };
        if (error) {
        } else {
            m_properties.append(p);
        }
    }

    for (int i = 0; i < m_children.count(); ++i) {
        m_children.at(i)->resolveProperties(m_absolutePath);
    }

#else
    Q_UNUSED(parentPath);
#endif
}

#ifndef GCONF_DISABLED

template <typename T> T fromGConfValue(GConfValue *value) { return T(); }
template <> QString fromGConfValue<QString>(GConfValue *value) { return QString::fromUtf8(gconf_value_get_string(value)); }
template <> int fromGConfValue<int>(GConfValue *value) { return gconf_value_get_int(value); }
template <> double fromGConfValue<double>(GConfValue *value) { return gconf_value_get_float(value); }
template <> bool fromGConfValue<bool>(GConfValue *value) { return gconf_value_get_bool(value); }

template <typename List, typename T> List fromGConfList(GConfValue *value)
{
    List list;
    for (GSList *it = gconf_value_get_list(value); it; it = it->next) {
        list.append(fromGConfValue<T>(reinterpret_cast<GConfValue *>(it->data)));
    }
    return list;
}

template <> QVariant fromGConfValue<QVariant>(GConfValue *value)
{
    switch (value->type) {
    case GCONF_VALUE_STRING: return fromGConfValue<QString>(value);
    case GCONF_VALUE_INT:    return fromGConfValue<int>(value);
    case GCONF_VALUE_FLOAT:  return fromGConfValue<double>(value);
    case GCONF_VALUE_BOOL:   return fromGConfValue<bool>(value);
    case GCONF_VALUE_LIST:
        switch (gconf_value_get_list_type(value)) {
        case GCONF_VALUE_STRING: return fromGConfList<QStringList, QString>(value);
        case GCONF_VALUE_INT:    return fromGConfList<QVariantList, int>(value);
        case GCONF_VALUE_FLOAT:  return fromGConfList<QVariantList, double>(value);
        case GCONF_VALUE_BOOL:   return fromGConfList<QVariantList, bool>(value);
        default: return QVariant();
        }
        break;
    case GCONF_VALUE_PAIR:
        return QVariant();
    case GCONF_VALUE_INVALID:
        return QVariant();
    default:
        return QVariant();
    }
}

void DeclarativeGConfSettings::readValue(const QMetaProperty &property, GConfValue *value)
{
    QVariant variant = fromGConfValue<QVariant>(value);
    if (variant.isValid()) {
        property.write(this, variant);
    }
}

void DeclarativeGConfSettings::cancelNotifications()
{
    for (int i = 0; i < m_properties.count(); ++i) {
        gconf_client_notify_remove(m_client, m_properties.at(i).notifyId);
    }
    m_properties.clear();
}

void DeclarativeGConfSettings::notify(GConfClient *, guint cnxn_id, GConfEntry *entry, gpointer user_data)
{
    DeclarativeGConfSettings * const settings = static_cast<DeclarativeGConfSettings *>(user_data);
    for (int i = 0; i < settings->m_properties.count(); ++i) {
        const Property &property = settings->m_properties.at(i);
        if (property.notifyId == cnxn_id) {
            settings->m_readPropertyIndex = i;
            settings->readValue(
                        settings->metaObject()->property(property.propertyIndex),
                        gconf_entry_get_value(entry));
            settings->m_readPropertyIndex = -1;
            break;
        }
    }
}

DeclarativeGConf::DeclarativeGConf(QObject *parent)
    : QObject(parent = 0)
    , m_client(0)
{
#ifndef GCONF_DISABLED
    m_client = gconf_client_get_default();
#endif
}

DeclarativeGConf::~DeclarativeGConf()
{
#ifndef GCONF_DISABLED
    g_object_unref(m_client);
#endif
}

DeclarativeGConf *DeclarativeGConf::qmlAttachedProperties(QObject *parent)
{
    return new DeclarativeGConf(parent);
}

QVariant DeclarativeGConf::read(const QString &key)
{
#ifndef GCONF_DISABLED
    GError *error = 0;
    if (GConfValue *value = gconf_client_get(m_client, key.toUtf8().constData(), &error)) {
        QVariant variant = fromGConfValue<QVariant>(value);
        gconf_value_free(value);
        return variant;
    } else if (error) {
        qmlInfo(this) << "Failed to get value for " << key;
        qmlInfo(this) << error->message;
        g_error_free(error);
    }
#endif
    return QVariant();

}

void DeclarativeGConf::write(const QString &key, const QVariant &variant)
{
#ifndef GCONF_DISABLED
    GError *error = 0;
    if (GConfValue *value = toGConfValue<QVariant>(variant)) {
        gconf_client_set(m_client, key.toUtf8().constData(), value, &error);
        gconf_value_free(value);
    } else if (variant.isValid()) {
        gconf_client_unset(m_client, key.toUtf8().constData(), &error);
    }

    if (error) {
        qmlInfo(this) << "Failed to get value for " << key << variant;
        qmlInfo(this) << error->message;
        g_error_free(error);
    }
#else
    Q_UNUSED(key);
    Q_UNUSED(variant);
#endif
}

#endif
