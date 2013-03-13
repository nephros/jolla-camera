#include "declarativefocus.h"

#include <QCamera>

DeclarativeFocusZoneModel::DeclarativeFocusZoneModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

DeclarativeFocusZoneModel::~DeclarativeFocusZoneModel()
{
}

QModelIndex DeclarativeFocusZoneModel::index(int row, int column, const QModelIndex &parent) const
{
    return !parent.isValid() && row >= 0 && row < m_zones.count() && column == 0
            ? createIndex(row, column)
            : QModelIndex();
}

int DeclarativeFocusZoneModel::rowCount(const QModelIndex &parent) const
{
    return !parent.isValid() ? m_zones.count() : 0;
}

QVariant DeclarativeFocusZoneModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    QCameraFocusZone zone = m_zones.at(index.row());

    switch (role) {
    case AreaRole:
        return zone.area();
    case StatusRole:
        return zone.status();
    default:
        return QVariant();
    }
}

void DeclarativeFocusZoneModel::setZones(const QList<QCameraFocusZone> &zones)
{
    // Try and match up existing zones with new ones and emit more granular signals,
    // as that may allow the zones to animate as the move.
    beginResetModel();
    m_zones = zones;
    endResetModel();
}

DeclarativeFocus::DeclarativeFocus(QCamera *camera, QObject *parent)
    : QObject(parent)
    , m_camera(camera)
    , m_control(0)
    , m_mode(OneShot)
    , m_target(Scene)
    , m_distance(Normal)
{
    m_control = m_camera->service()->requestControl<QCameraFocusControl *>();
}

DeclarativeFocus::~DeclarativeFocus()
{
    if (m_control) {
        m_camera->service()->releaseControl(m_control);
    }
}

DeclarativeFocus::Mode DeclarativeFocus::mode() const
{
    return m_mode;
}

void DeclarativeFocus::setMode(Mode mode)
{
    if (m_mode != mode) {
        m_mode = mode;
        if (m_control) {
            m_control->setFocusMode(QCameraFocus::FocusMode(m_mode | m_mode));
        }
        emit modeChanged();
    }
}

DeclarativeFocus::Target DeclarativeFocus::target() const
{
    return m_target;
}

void DeclarativeFocus::setTarget(Target target)
{
    if (m_target != target) {
        m_target = target;
        if (m_control) {
            m_control->setFocusPointMode(QCameraFocus::FocusPointMode(target));
        }
        emit targetChanged();
    }
}

DeclarativeFocus::Distance DeclarativeFocus::distance() const
{
    return m_distance;
}

void DeclarativeFocus::setDistance(Distance distance)
{
    if (m_distance != distance) {
        m_distance = distance;
        if (m_control) {
            m_control->setFocusMode(QCameraFocus::FocusMode(m_mode | m_distance));
        }
        emit distanceChanged();
    }
}

DeclarativeFocusZoneModel *DeclarativeFocus::focusZones()
{
    if (!m_focusZones) {
        m_focusZones = new DeclarativeFocusZoneModel(this);
        if (m_control) {
            m_focusZones->setZones(m_control->focusZones());
            connect(m_control, SIGNAL(focusZonesChanged()), this, SLOT(updateFocusZones));
        }
    }
    return m_focusZones;
}

void DeclarativeFocus::focusOnPoint(qreal x, qreal y)
{
    if (m_control) {
        m_control->setCustomFocusPoint(QPointF(x, y));
    }
}

void DeclarativeFocus::updateFocusZones()
{
    m_focusZones->setZones(m_control->focusZones());
}
