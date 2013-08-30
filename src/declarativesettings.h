#ifndef DECLARATIVESETTINGS_H
#define DECLARATIVESETTINGS_H

#include <QObject>
#include <QDate>

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

    QString photoDirectory() const;
    QString videoDirectory() const;

    Q_INVOKABLE QString photoCapturePath(const QString &extension);
    Q_INVOKABLE QString videoCapturePath(const QString &extension);

private:
    void verifyCapturePrefix();

    QString m_prefix;
    QDate m_prefixDate;
    int m_photoCounter;
    int m_videoCounter;
};

#endif

