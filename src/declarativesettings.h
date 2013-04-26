#ifndef DECLARATIVESETTINGS_H
#define DECLARATIVESETTINGS_H

#include <QObject>
#include <QSize>

#ifndef DESKTOP
#include <MGConfItem>
#else
#include <QVariant>
class MGConfItem : public QObject
{
    Q_OBJECT
public:
    MGConfItem(const QString &) {}

    QVariant value(const QVariant &defaultValue) const { return m_value.isValid() ? m_value : defaultValue; }
    void set(const QVariant &value) { if (m_value != value) { m_value = value; emit valueChanged(); } }

signals:
    void valueChanged();

private:
    QVariant m_value;
};
#endif

QT_BEGIN_NAMESPACE
class QQmlEngine;
class QJSEngine;
QT_END_NAMESPACE

class DeclarativeSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(ShootingMode shootingMode READ shootingMode WRITE setShootingMode NOTIFY shootingModeChanged)
    Q_PROPERTY(Properties shootingModeProperties READ shootingModeProperties NOTIFY shootingModeChanged)
    Q_PROPERTY(AspectRatioEnum aspectRatio READ aspectRatio WRITE setAspectRatio NOTIFY aspectRatioChanged)
    Q_PROPERTY(int iso READ iso WRITE setIso NOTIFY isoChanged)
    Q_PROPERTY(int effectiveIso READ effectiveIso NOTIFY isoChanged)
    Q_PROPERTY(int whiteBalance READ whiteBalance WRITE setWhiteBalance NOTIFY whiteBalanceChanged)
    Q_PROPERTY(int effectiveWhiteBalance READ effectiveWhiteBalance NOTIFY whiteBalanceChanged)
    Q_PROPERTY(int focusDistance READ focusDistance WRITE setFocusDistance NOTIFY focusDistanceChanged)
    Q_PROPERTY(int videoFocus READ videoFocus WRITE setVideoFocus NOTIFY videoFocusChanged)
    Q_PROPERTY(int effectiveFocusDistance READ effectiveFocusDistance NOTIFY focusDistanceChanged)
    Q_PROPERTY(int flash READ flash WRITE setFlash NOTIFY flashChanged)
    Q_PROPERTY(int effectiveFlash READ effectiveFlash NOTIFY flashChanged)
    Q_PROPERTY(qreal exposureCompensation READ exposureCompensation WRITE setExposureCompensation NOTIFY exposureChanged)
    Q_PROPERTY(int exposureMode READ exposureMode NOTIFY exposureChanged)
    Q_PROPERTY(QString photoDirectory READ photoDirectory CONSTANT)
    Q_PROPERTY(QString videoDirectory READ videoDirectory CONSTANT)
    Q_ENUMS(ShootingMode)
    Q_ENUMS(AspectRatioEnum)
    Q_FLAGS(Properties)
public:
    enum ShootingMode {
        Auto,
        Program,
        Macro,
        Sports,
        Landscape,
        Portrait
    };

    enum AspectRatioEnum {
        AspectRatio_4_3,
        AspectRatio_16_9
    };

    enum PropertyFlag {
        AspectRatio = 0x01,
        Iso = 0x02,
        WhiteBalance = 0x04,
        FocusDistance = 0x08,
        Flash = 0x10,
        Exposure = 0x20
    };

    Q_DECLARE_FLAGS(Properties, PropertyFlag)

    DeclarativeSettings(QObject *parent = 0);
    ~DeclarativeSettings();

    static QObject *factory(QQmlEngine *, QJSEngine *);

    Q_INVOKABLE QSize defaultImageResolution(AspectRatioEnum ratio) const;
    Q_INVOKABLE QSize defaultVideoResolution(AspectRatioEnum ratio) const;

    ShootingMode shootingMode() const;
    void setShootingMode(ShootingMode mode);

    Properties shootingModeProperties() const;

    AspectRatioEnum aspectRatio() const;
    void setAspectRatio(AspectRatioEnum ratio);

    int iso() const;
    int effectiveIso() const;
    void setIso(int iso);
    bool shootingModeIso() const;

    int whiteBalance() const;
    int effectiveWhiteBalance() const;
    void setWhiteBalance(int balance);
    bool shootingModeWhiteBalance() const;

    int focusDistance() const;
    int effectiveFocusDistance() const;
    void setFocusDistance(int distance);
    bool shootingModeFocusDistance() const;

    int videoFocus() const;
    void setVideoFocus(int focus);

    int flash() const;
    int effectiveFlash() const;
    void setFlash(int flash);
    bool shootingModeFlash() const;

    qreal exposureCompensation() const;
    void setExposureCompensation(qreal compensation);
    int exposureMode() const;
    bool shootingModeExposure() const;

    QString photoDirectory() const;
    QString videoDirectory() const;

signals:
    void shootingModeChanged();
    void aspectRatioChanged();
    void isoChanged();
    void whiteBalanceChanged();
    void focusDistanceChanged();
    void videoFocusChanged();
    void flashChanged();
    void exposureChanged();

private:
    MGConfItem m_imageRatio_4_3;
    MGConfItem m_imageRatio_16_9;
    MGConfItem m_videoRatio_4_3;
    MGConfItem m_videoRatio_16_9;
    MGConfItem m_shootingMode;
    MGConfItem m_aspectRatio;
    MGConfItem m_iso;
    MGConfItem m_whiteBalance;
    MGConfItem m_focusDistance;
    MGConfItem m_videoFocus;
    MGConfItem m_flash;
    MGConfItem m_exposureCompensation;
};

#endif

