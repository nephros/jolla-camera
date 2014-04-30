#ifndef DECLARATIVESETTINGS_H
#define DECLARATIVESETTINGS_H

#include <QSocketNotifier>
#include <QDate>

#include <QUrl>
#include <MGConfItem>

QT_BEGIN_NAMESPACE
class QQmlEngine;
class QJSEngine;
QT_END_NAMESPACE

class DeclarativeSettings : public QSocketNotifier
{
    Q_OBJECT
    Q_PROPERTY(QString photoDirectory READ photoDirectory CONSTANT)
    Q_PROPERTY(QString videoDirectory READ videoDirectory CONSTANT)
    Q_PROPERTY(bool locationEnabled READ locationEnabled NOTIFY locationEnabledChanged)
public:
    DeclarativeSettings(QObject *parent = 0);
    ~DeclarativeSettings();

    static QObject *factory(QQmlEngine *, QJSEngine *);

    bool locationEnabled() const;

    QString photoDirectory() const;
    QString videoDirectory() const;

    Q_INVOKABLE QString photoCapturePath(const QString &extension);
    Q_INVOKABLE QString videoCapturePath(const QString &extension);

    Q_INVOKABLE QUrl completeCapture(const QUrl &file);

    bool event(QEvent *event);

signals:
    void locationEnabledChanged();

private:
    void verifyCapturePrefix();
    void updateLocation();

    MGConfItem m_counter;
    MGConfItem m_counterDate;

    QString m_prefix;
    QDate m_prefixDate;

    int m_locationWatch;
    bool m_locationEnabled;
};

#endif

