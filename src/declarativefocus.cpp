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
{
    if (QMediaService *service = m_camera->service())
        m_control = service->requestControl<QCameraFocusControl *>();
}

DeclarativeFocus::~DeclarativeFocus()
{
    if (m_control) {
        m_camera->service()->releaseControl(m_control);
    }
}

DeclarativeCamera::FocusMode DeclarativeFocus::mode() const
{
    return m_control
            ? DeclarativeCamera::FocusMode(m_control->focusMode())
            : DeclarativeCamera::FocusAuto;
}

void DeclarativeFocus::setMode(DeclarativeCamera::FocusMode mode)
{
    if (m_control) {
        m_control->setFocusMode(QCameraFocus::FocusMode(mode));
        emit modeChanged();
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

DeclarativeCamera::FocusPointMode DeclarativeFocus::focusPointMode() const
{
    return m_control
            ? DeclarativeCamera::FocusPointMode(m_control->focusPointMode())
            : DeclarativeCamera::FocusPointAuto;
}

void DeclarativeFocus::setFocusPointMode(DeclarativeCamera::FocusPointMode mode)
{
    if (m_control) {
        m_control->setFocusPointMode(QCameraFocus::FocusPointMode(mode));
        emit focusPointModeChanged();
    }
}

QPointF DeclarativeFocus::customFocusPoint() const
{
    return m_control ? m_control->customFocusPoint() : QPointF();
}

void DeclarativeFocus::setCustomFocusPoint(const QPointF &point)
{
    if (m_control) {
        m_control->setCustomFocusPoint(point);
        emit customFocusPointChanged();
    }
}

void DeclarativeFocus::focusOnPoint(qreal x, qreal y)
{
    if (m_control) {
        m_control->setCustomFocusPoint(QPointF(x, y));
        emit customFocusPointChanged();
    }
}

void DeclarativeFocus::updateFocusZones()
{
    m_focusZones->setZones(m_control->focusZones());
}
