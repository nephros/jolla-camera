
#include "declarativegconfsettings.h"

#include <QQmlInfo>

#include <QMetaProperty>
#include <QPoint>
#include <QSize>
#include <QStringList>

DeclarativeGConfSettings::DeclarativeGConfSettings(QObject *parent)
    : QObject(parent)
    , m_parent(0)
#ifndef GCONF_DISABLED
    , m_client(0)
    , m_notifyId(0)
#endif
    , m_readPropertyIndex(-1)
{
}

DeclarativeGConfSettings::~DeclarativeGConfSettings()
{
#ifndef GCONF_DISABLED
    if (m_client) {
        if (!m_parent && !m_absolutePath.isEmpty()) {
            m_absolutePath.chop(1);
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

    if (m_path.startsWith(QLatin1Char('/'))) {
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
                m_absolutePath.chop(1);
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

QQmlListProperty<QObject> DeclarativeGConfSettings::data()
{
    return QQmlListProperty<QObject>(this, 0, data_append, data_count, data_at, data_clear);
}

void DeclarativeGConfSettings::data_append(QQmlListProperty<QObject> *property, QObject *value)
{
    DeclarativeGConfSettings *settings = static_cast<DeclarativeGConfSettings *>(property->object);
    settings->m_data.append(value);
    if (DeclarativeGConfSettings *child = qobject_cast<DeclarativeGConfSettings *>(value)) {
        settings->m_children.append(child);
        child->m_parent = settings;
    }
}

QObject *DeclarativeGConfSettings::data_at(QQmlListProperty<QObject> *property, int index)
{
    return static_cast<DeclarativeGConfSettings *>(property->object)->m_data.at(index);
}

int DeclarativeGConfSettings::data_count(QQmlListProperty<QObject> *property)
{
    return static_cast<DeclarativeGConfSettings *>(property->object)->m_data.count();
}

void DeclarativeGConfSettings::data_clear(QQmlListProperty<QObject> *)
{
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

template <> GConfValue *toGConfValue<QSize>(const QVariant &variant)
{
    const QSize size = variant.toSize();
    GConfValue *value = gconf_value_new(GCONF_VALUE_PAIR);
    gconf_value_set_car_nocopy(value, toGConfValue<int>(size.width()));
    gconf_value_set_cdr_nocopy(value, toGConfValue<int>(size.height()));
    return value;
}

template <> GConfValue *toGConfValue<QSizeF>(const QVariant &variant)
{
    const QSizeF size = variant.toSizeF();
    GConfValue *value = gconf_value_new(GCONF_VALUE_PAIR);
    gconf_value_set_car_nocopy(value, toGConfValue<double>(size.width()));
    gconf_value_set_cdr_nocopy(value, toGConfValue<double>(size.height()));
    return value;
}

template <> GConfValue *toGConfValue<QPoint>(const QVariant &variant)
{
    const QPoint size = variant.toPoint();
    GConfValue *value = gconf_value_new(GCONF_VALUE_PAIR);
    gconf_value_set_car_nocopy(value, toGConfValue<int>(size.x()));
    gconf_value_set_cdr_nocopy(value, toGConfValue<int>(size.y()));
    return value;
}

template <> GConfValue *toGConfValue<QPointF>(const QVariant &variant)
{
    const QPointF size = variant.toPointF();
    GConfValue *value = gconf_value_new(GCONF_VALUE_PAIR);
    gconf_value_set_car_nocopy(value, toGConfValue<double>(size.x()));
    gconf_value_set_cdr_nocopy(value, toGConfValue<double>(size.y()));
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

static GConfValue *fromVariant(const QVariant &variant)
{
    switch (variant.type()) {
    case QVariant::Invalid:    return 0;
    case QVariant::String:     return toGConfValue<QString>(variant);
    case QVariant::Int:        return toGConfValue<int>(variant);
    case QVariant::UInt:       return toGConfValue<int>(variant);
    case QVariant::Double:     return toGConfValue<double>(variant);
    case QVariant::Bool:       return toGConfValue<bool>(variant);
    case QVariant::StringList: return toGConfValue<QStringList>(variant);
    case QVariant::Point:      return toGConfValue<QPoint>(variant);
    case QVariant::PointF:     return toGConfValue<QPointF>(variant);
    case QVariant::Size:       return toGConfValue<QSize>(variant);
    case QVariant::SizeF:      return toGConfValue<QSizeF>(variant);
    default:
        if (variant.userType() == qMetaTypeId<QVariantList>()) {
            QVariantList list = variant.value<QVariantList>();
            if (list.isEmpty()) {
                return 0;
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
            if (GConfValue *value = fromVariant(variant)) {
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

    GError *error = 0;

    m_absolutePath = parentPath + m_path.toUtf8();
    m_notifyId = gconf_client_notify_add(m_client, m_absolutePath.constData(), notify, this, 0, &error);
    if (error) {
        qmlInfo(this) << "Failed to register notifications for " << m_absolutePath;
        qmlInfo(this) << error->message;
        g_error_free(error);
        error = 0;
    }
    m_absolutePath += '/';

    const QMetaObject * const metaObject = this->metaObject();
    if (metaObject != &staticMetaObject) {
        for (int i = metaObject->propertyOffset(); i < metaObject->propertyCount(); ++i) {
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

static QVariant toVariant(GConfValue *value, int typeHint = 0)
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
    case GCONF_VALUE_PAIR: {
        GConfValue *first = gconf_value_get_car(value);
        GConfValue *second = gconf_value_get_cdr(value);
        if (!first || !second) {
            return QVariant();
        } else if (first->type == GCONF_VALUE_INT && second->type == GCONF_VALUE_INT) {
            switch (typeHint) {
            case QVariant::Point:
            case QVariant::PointF:
                return QVariant(QPoint(gconf_value_get_int(first), gconf_value_get_int(second)));
            case QVariant::Size:
            case QVariant::SizeF:
            default:    //
                return QVariant(QSize(gconf_value_get_int(first), gconf_value_get_int(second)));
            }
        } else if (first->type == GCONF_VALUE_FLOAT && second->type == GCONF_VALUE_FLOAT) {
            switch (typeHint) {
            case QVariant::Point:
            case QVariant::PointF:
                return QVariant(QPointF(gconf_value_get_float(first), gconf_value_get_float(second)));
            case QVariant::Size:
            case QVariant::SizeF:
            default:
                return QVariant(QSizeF(gconf_value_get_float(first), gconf_value_get_float(second)));
            }
        }
        return QVariant();
    }
    case GCONF_VALUE_INVALID:
        return QVariant();
    default:
        return QVariant();
    }
}

void DeclarativeGConfSettings::readValue(const QMetaProperty &property, GConfValue *value)
{
    int typeHint = 0;
    if (value->type == GCONF_VALUE_PAIR)
        typeHint = property.read(this).type();
    QVariant variant = toVariant(value, typeHint);
    if (variant.isValid()) {
        property.write(this, variant);
    }
}

void DeclarativeGConfSettings::cancelNotifications()
{
    if (m_notifyId) {
        gconf_client_notify_remove(m_client, m_notifyId);
        m_notifyId = 0;
    }
}

void DeclarativeGConfSettings::notify(GConfClient *, guint cnxn_id, GConfEntry *entry, gpointer user_data)
{
    DeclarativeGConfSettings * const settings = static_cast<DeclarativeGConfSettings *>(user_data);
    if (cnxn_id != settings->m_notifyId)
        return;

    const QByteArray key = gconf_entry_get_key(entry);
    const int pathLength = key.lastIndexOf('/');
    if (pathLength + 1 == settings->m_absolutePath.count()
            && key.startsWith(settings->m_absolutePath)) {
        const QMetaObject *const metaObject = settings->metaObject();
        settings->m_readPropertyIndex = metaObject->indexOfProperty(key.mid(pathLength + 1));
        if (settings->m_readPropertyIndex >= metaObject->propertyOffset()) {
            settings->readValue(
                        metaObject->property(settings->m_readPropertyIndex),
                        gconf_entry_get_value(entry));
        }
        settings->m_readPropertyIndex = -1;
    }
}

#endif

DeclarativeGConf::DeclarativeGConf(QObject *parent)
    : QObject(parent = 0)
#ifndef GCONF_DISABLED
    , m_client(0)
#endif
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
        QVariant variant = toVariant(value);
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
    if (GConfValue *value = fromVariant(variant)) {
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

