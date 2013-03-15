#ifndef DECLARATIVEFOCUS_H
#define DECLARATIVEFOCUS_H

#include <QAbstractItemModel>
#include <QRectF>

#include "qcamerafocuscontrol.h"

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
    Q_PROPERTY(Mode mode READ mode WRITE setMode NOTIFY modeChanged)
    Q_PROPERTY(Target target READ target WRITE setTarget NOTIFY targetChanged)
    Q_PROPERTY(Distance distance READ distance WRITE setDistance NOTIFY distanceChanged)
    Q_ENUMS(Mode)
    Q_ENUMS(Target)
    Q_ENUMS(Distance)
public:

    enum Mode
    {
        Fixed       = QCameraFocus::ManualFocus,
        OneShot     = QCameraFocus::AutoFocus,
        Continuous  = QCameraFocus::ContinuousFocus
    };

    enum Target
    {
        Scene   = QCameraFocus::FocusPointAuto,
        Center  = QCameraFocus::FocusPointCenter,
        Faces   = QCameraFocus::FocusPointFaceDetection,
        Point   = QCameraFocus::FocusPointCustom
    };

    enum Distance
    {
        Normal      = 0,
        Hyperfocal  = QCameraFocus::HyperfocalFocus,
        Infinite    = QCameraFocus::InfinityFocus,
        Macro       = QCameraFocus::MacroFocus
    };

    DeclarativeFocus(QCamera *camera, QObject *parent);
    ~DeclarativeFocus();

    Mode mode() const;
    void setMode(Mode mode);

    Target target() const;
    void setTarget(Target target);

    Distance distance() const;
    void setDistance(Distance distance);

    DeclarativeFocusZoneModel *focusZones();

public Q_SLOTS:
    void focusOnPoint(qreal x, qreal y);

Q_SIGNALS:
    void modeChanged();
    void targetChanged();
    void distanceChanged();

private Q_SLOTS:
    void updateFocusZones();

private:
    QCamera *m_camera;
    QCameraFocusControl *m_control;
    DeclarativeFocusZoneModel *m_focusZones;
    Mode m_mode;
    Target m_target;
    Distance m_distance;
};

#endif
