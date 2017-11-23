
#include "declarativesettings.h"

#include <QDebug>
#include <QDir>
#include <QDirIterator>
#include <QEvent>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QSettings>
#include <QStandardPaths>
#include <QLocale>
#include <QTemporaryFile>
#include <partitionmanager.h>

DeclarativeSettings::DeclarativeSettings(QObject *parent)
    : QObject(parent)
    , m_partitionManager(new PartitionManager(this))
    , m_storagePath(QStringLiteral("/apps/jolla-camera/storagePath"))
    , m_locationEnabled(false)
    , m_storagePathStatus(NotSet)
{
    connect(&m_storagePath, SIGNAL(valueChanged()), this, SLOT(verifyStoragePath()));
    connect(m_partitionManager, SIGNAL(partitionRemoved(const Partition&)), this, SLOT(verifyStoragePath()));
    connect(m_partitionManager, SIGNAL(partitionAdded(const Partition&)), this, SLOT(verifyStoragePath()));
    connect(m_partitionManager, SIGNAL(partitionChanged(const Partition&)), this, SLOT(verifyStoragePath()));

    verifyStoragePath();

    // protect against camera crashes leaving files in the hidden directory
    for (const QFileInfo &info : QDir(videoDirectory() + QLatin1String("/.recording")).entryInfoList(QDir::Files)) {
        QFile(info.absoluteFilePath()).rename(videoDirectory() + info.fileName());
    }

    updateLocation();
}

DeclarativeSettings::~DeclarativeSettings()
{

}

QObject *DeclarativeSettings::factory(QQmlEngine *engine, QJSEngine *)
{
    const QUrl source = QUrl::fromLocalFile(QStringLiteral(DEPLOYMENT_PATH "settings.qml"));
    QQmlComponent component(engine, source);
    if (component.isReady()) {
        return component.create();
    } else {
        qWarning() << "Failed to instantiate Settings";
        qWarning() << component.errors();
        return 0;
    }
}

bool DeclarativeSettings::locationEnabled() const
{
    return m_locationEnabled;
}

void DeclarativeSettings::updateLocation()
{
    QSettings locationSettings(QStringLiteral("/etc/location/location.conf"), QSettings::IniFormat);
    locationSettings.beginGroup(QStringLiteral("location"));

    bool locationEnabled = locationSettings.value(QStringLiteral("enabled")).toBool();
    if (m_locationEnabled != locationEnabled) {
        m_locationEnabled = locationEnabled;
        emit locationEnabledChanged();
    }
}

QString DeclarativeSettings::photoDirectory() const
{
    return m_photoDirectory;
}

QString DeclarativeSettings::videoDirectory() const
{
    return m_videoDirectory;
}

QString DeclarativeSettings::storagePath() const
{
    return m_storagePath.value().toString();
}

void DeclarativeSettings::setStoragePath(const QString &path)
{
    if (path == storagePath())
        return;

    if (path.isEmpty()) {
        m_storagePath.unset();
        m_storagePathStatus = NotSet;
    } else {
        m_storagePath.set(path);
    }

    // notifiers will be handled by the MGConfItem change signal connection
}

DeclarativeSettings::StoragePathStatus DeclarativeSettings::storagePathStatus() const
{
    return m_storagePathStatus;
}

bool DeclarativeSettings::verifyWritable(const QString &path)
{
    QTemporaryFile file(path + QStringLiteral("/XXXXXX.tmp"));
    file.setAutoRemove(true);
    return file.open();
}

void DeclarativeSettings::verifyStoragePath()
{
    const QString prevPhotoPath = m_photoDirectory;
    const QString prevVideoPath = m_videoDirectory;

    QString path = storagePath();
    StoragePathStatus oldStatus = m_storagePathStatus;

    m_storagePathStatus = path.isEmpty() ? NotSet : Unavailable;

    if (!path.isEmpty()) {
        QVector<Partition> partitions = m_partitionManager->partitions(Partition::External | Partition::ExcludeParents);
        auto it = std::find_if(partitions.begin(), partitions.end(), [path](const Partition &partition) { return partition.mountPath() == path; });
        if (it != partitions.end()) {
            const Partition &partition = *it;
            if (partition.status() == Partition::Mounted) {
                m_storagePathStatus = verifyWritable(storagePath()) ? Available : Unavailable;
            } else if(partition.status() == Partition::Mounting) {
                m_storagePathStatus = Mounting;
            }
        }
    }

    if (m_storagePathStatus == Available && !path.isEmpty()) {
        m_photoDirectory = path + QStringLiteral("/Pictures/Camera");
        m_videoDirectory = path + QStringLiteral("/Videos/Camera");
    } else {
        m_photoDirectory = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation) + QLatin1String("/Camera");
        m_videoDirectory = QStandardPaths::writableLocation(QStandardPaths::MoviesLocation) + QLatin1String("/Camera");
    }

    QDir(m_photoDirectory).mkpath(QLatin1String("."));
    QDir(m_videoDirectory).mkpath(QLatin1String(".recording"));

    if (prevPhotoPath != m_photoDirectory) {
        emit photoDirectoryChanged();
    }
    if (prevVideoPath != m_videoDirectory) {
        emit videoDirectoryChanged();
    }

    if (oldStatus != m_storagePathStatus)
        emit storagePathStatusChanged();
}

QString DeclarativeSettings::photoCapturePath(const QString &extension)
{
    verifyCapturePrefix();

    QString fileFormat(photoDirectory() + QLatin1Char('/') + m_prefix + QLatin1String("%1.") + extension);
    return capturePath(fileFormat);
}

QString DeclarativeSettings::videoCapturePath(const QString &extension)
{
    verifyCapturePrefix();

    QString fileFormat(videoDirectory() + QLatin1String("/.recording/") + m_prefix + QLatin1String("%1.") + extension);
    return capturePath(fileFormat);
}

QUrl DeclarativeSettings::completeCapture(const QUrl &file)
{
    const QString recordingDir = QStringLiteral("/.recording/");
    const QString absolutePath = file.toLocalFile();
    const int index = absolutePath.lastIndexOf(recordingDir) + 1;
    if (index == -1) {
        return file;
    }

    QString targetPath = absolutePath;
    targetPath.remove(index, recordingDir.length() - 1);

    if (QFile::rename(absolutePath, targetPath)) {
        return QUrl::fromLocalFile(targetPath);
    } else {
        QFile::remove(absolutePath);
        return QUrl();
    }
}

void DeclarativeSettings::verifyCapturePrefix()
{
    const QDateTime currentDate = QDateTime::currentDateTime();
    if (m_prefixDate != currentDate) {
        m_prefixDate = currentDate;
        m_prefix = QLocale::c().toString(currentDate, QLatin1String("yyyyMMdd_HHmmss"));
    }
}

QString DeclarativeSettings::capturePath(const QString &format)
{
    QString path = format.arg(QString(""));
    if (!QFile::exists(path)) {
        return path;
    }

    int counter = 1;
    for (;;) {
        path = format.arg(QString(QStringLiteral("_%1")).arg(counter, 3, 10, QLatin1Char('0')));
        if (!QFile::exists(path))
            return path;
        ++counter;
    }
}
