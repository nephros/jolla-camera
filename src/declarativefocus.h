#ifndef DECLARATIVEFOCUS_H
#define DECLARATIVEFOCUS_H

#include <QAbstractItemModel>
#include <QRectF>

#include "qcamerafocuscontrol.h"

#include "declarativecamera.h"

class DeclarativeFocusZoneModel : public QAbstractListModel
{
    Q_OBJECT
    Q_ENUMS(Status)
public:
    enum Status
    {
        Null        = QCameraFocusZone::Invalid,
        Unused      = QCameraFocusZone::Unused,
        Selected    = QCameraFocusZone::Selected,
        Focused     = QCameraFocusZone::Focused
    };

    enum Roles
    {
        AreaRole,
        StatusRole
    };

    DeclarativeFocusZoneModel(QObject *parent = 0);
    ~DeclarativeFocusZoneModel();

    QModelIndex index(int row, int column, const QModelIndex &parent) const;
    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;

    void setZones(const QList<QCameraFocusZone> &zones);

private:
    QList<QCameraFocusZone> m_zones;
};

class DeclarativeFocus : public QObject
{
    Q_OBJECT
    Q_PROPERTY(DeclarativeCamera::FocusMode focusMode READ mode WRITE setMode NOTIFY modeChanged)
    Q_PROPERTY(DeclarativeCamera::FocusPointMode focusPointMode READ focusPointMode WRITE setFocusPointMode NOTIFY focusPointModeChanged)
    Q_PROPERTY(QPointF customFocusPoint READ customFocusPoint WRITE setCustomFocusPoint NOTIFY customFocusPointChanged)
    Q_ENUMS(DeclarativeCamera::FocusMode)
public:
    DeclarativeFocus(QCamera *camera, QObject *parent);
    ~DeclarativeFocus();


    DeclarativeCamera::FocusMode mode() const;
    void setMode(DeclarativeCamera::FocusMode mode);

    DeclarativeCamera::FocusPointMode focusPointMode() const;
    void setFocusPointMode(DeclarativeCamera::FocusPointMode mode);

    QPointF customFocusPoint() const;
    void setCustomFocusPoint(const QPointF &point);

    DeclarativeFocusZoneModel *focusZones();

public Q_SLOTS:
    void focusOnPoint(qreal x, qreal y);

Q_SIGNALS:
    void modeChanged();
    void focusPointModeChanged();
    void customFocusPointChanged();

private Q_SLOTS:
    void updateFocusZones();

private:
    QCamera *m_camera;
    QCameraFocusControl *m_control;
    DeclarativeFocusZoneModel *m_focusZones;
};

#endif
