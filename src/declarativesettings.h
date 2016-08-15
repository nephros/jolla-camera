#ifndef DECLARATIVESETTINGS_H
#define DECLARATIVESETTINGS_H

#include <QObject>
#include <QDateTime>

#include <QUrl>
#include <MGConfItem>

QT_BEGIN_NAMESPACE
class QQmlEngine;
class QJSEngine;
QT_END_NAMESPACE

class PartitionManager;

class DeclarativeSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString photoDirectory READ photoDirectory NOTIFY photoDirectoryChanged)
    Q_PROPERTY(QString videoDirectory READ videoDirectory NOTIFY videoDirectoryChanged)
    Q_PROPERTY(QString storagePath READ storagePath WRITE setStoragePath NOTIFY storagePathChanged)
    Q_PROPERTY(StoragePathStatus storagePathStatus READ storagePathStatus NOTIFY storagePathStatusChanged)
    Q_PROPERTY(bool locationEnabled READ locationEnabled NOTIFY locationEnabledChanged)
    Q_ENUMS(StoragePathStatus)
public:
    DeclarativeSettings(QObject *parent = 0);
    ~DeclarativeSettings();

    static QObject *factory(QQmlEngine *, QJSEngine *);

    bool locationEnabled() const;

    QString photoDirectory() const;
    QString videoDirectory() const;

    enum StoragePathStatus {
        NotSet,
        Unavailable,
        Mounting,
        Available
    };

    QString storagePath() const;
    void setStoragePath(const QString &path);
    StoragePathStatus storagePathStatus() const;

    Q_INVOKABLE QString photoCapturePath(const QString &extension);
    Q_INVOKABLE QString videoCapturePath(const QString &extension);

    Q_INVOKABLE QUrl completeCapture(const QUrl &file);

public slots:
    void updateLocation();

signals:
    void locationEnabledChanged();
    void photoDirectoryChanged();
    void videoDirectoryChanged();
    void storagePathChanged();
    void storagePathStatusChanged();

private slots:
    void verifyStoragePath();

private:
    bool verifyWritable(const QString &path);
    void verifyCapturePrefix();
    QString capturePath(const QString &format);

    PartitionManager *m_partitionManager;
    MGConfItem m_storagePath;

    QString m_prefix;
    QDateTime m_prefixDate;

    bool m_locationEnabled;
    StoragePathStatus m_storagePathStatus;
};

#endif

