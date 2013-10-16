#ifndef DECLARATIVESETTINGS_H
#define DECLARATIVESETTINGS_H

#include <QObject>
#include <QDate>

#include <MGConfItem>

QT_BEGIN_NAMESPACE
class QQmlEngine;
class QJSEngine;
QT_END_NAMESPACE

class DeclarativeSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString photoDirectory READ photoDirectory CONSTANT)
    Q_PROPERTY(QString videoDirectory READ videoDirectory CONSTANT)
    Q_ENUMS(Face)
    Q_ENUMS(AspectRatio)
public:
    enum Face {
        Back,
        Front
    };

    enum AspectRatio {
        AspectRatio_4_3,
        AspectRatio_16_9
    };

    DeclarativeSettings(QObject *parent = 0);
    ~DeclarativeSettings();

    static QObject *factory(QQmlEngine *, QJSEngine *);

    QString photoDirectory() const;
    QString videoDirectory() const;

    Q_INVOKABLE QString photoCapturePath(const QString &extension);
    Q_INVOKABLE QString videoCapturePath(const QString &extension);

private:
    void verifyCapturePrefix();

    MGConfItem m_counter;
    MGConfItem m_counterDate;

    QString m_prefix;
    QDate m_prefixDate;
};

#endif

