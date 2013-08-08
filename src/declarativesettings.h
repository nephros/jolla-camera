#ifndef DECLARATIVESETTINGS_H
#define DECLARATIVESETTINGS_H

#include <QObject>
#include <QDate>
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
    Q_PROPERTY(QString photoDirectory READ photoDirectory CONSTANT)
    Q_PROPERTY(QString videoDirectory READ videoDirectory CONSTANT)
public:
    DeclarativeSettings(QObject *parent = 0);
    ~DeclarativeSettings();

    static QObject *factory(QQmlEngine *, QJSEngine *);

    Q_INVOKABLE QSize defaultImageResolution(int ratio) const;
    Q_INVOKABLE QSize defaultVideoResolution(int ratio) const;

    QString photoDirectory() const;
    QString videoDirectory() const;

    Q_INVOKABLE QString photoCapturePath(const QString &extension);
    Q_INVOKABLE QString videoCapturePath(const QString &extension);

private:
    void verifyCapturePrefix();

    MGConfItem m_imageRatio_4_3;
    MGConfItem m_imageRatio_16_9;
    MGConfItem m_videoRatio_4_3;
    MGConfItem m_videoRatio_16_9;
    QString m_prefix;
    QDate m_prefixDate;
    int m_photoCounter;
    int m_videoCounter;
};

#endif

