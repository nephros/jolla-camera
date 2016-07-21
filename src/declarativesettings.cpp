
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
    , m_counter(QLatin1String("/apps/jolla-camera/captureCounter"))
    , m_counterDate(QLatin1String("/apps/jolla-camera/captureCounterDate"))
    , m_storagePath(QStringLiteral("/apps/jolla-camera/storagePath"))
    , m_locationEnabled(false)
    , m_storagePathStatus(Unavailable)
{
    m_prefixDate = QDate::fromString(m_counterDate.value().toString(), Qt::ISODate);
    m_prefix = QLocale::c().toString(m_prefixDate, QLatin1String("yyyyMMdd_"));

    connect(&m_storagePath, SIGNAL(valueChanged()), this, SLOT(verifyStoragePath()));
    connect(m_partitionManager, SIGNAL(partitionRemoved(const Partition&)), this, SLOT(verifyStoragePath()));
    connect(m_partitionManager, SIGNAL(partitionAdded(const Partition&)), this, SLOT(verifyStoragePath()));
    connect(m_partitionManager, SIGNAL(partitionChanged(const Partition&)), this, SLOT(verifyStoragePath()));

    verifyStoragePath();
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
    if (m_storagePathStatus == Available && !storagePath().isEmpty())
        return storagePath() + QStringLiteral("/Pictures/Camera");

    return QStandardPaths::writableLocation(QStandardPaths::PicturesLocation) + QLatin1String("/Camera");
}

QString DeclarativeSettings::videoDirectory() const
{
    if (m_storagePathStatus == Available && !storagePath().isEmpty())
        return storagePath() + QStringLiteral("/Videos/Camera");

    return QStandardPaths::writableLocation(QStandardPaths::MoviesLocation) + QLatin1String("/Camera");
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
    QString prevPhotoPath = photoDirectory();
    QString path = storagePath();
    StoragePathStatus oldStatus = m_storagePathStatus;

    m_storagePathStatus = Unavailable;

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

    QDir(photoDirectory()).mkpath(QLatin1String("."));
    QDir(videoDirectory()).mkpath(QLatin1String(".recording"));

    if (prevPhotoPath != photoDirectory()) {
        emit photoDirectoryChanged();
        emit videoDirectoryChanged();
    }
    if (oldStatus != m_storagePathStatus)
        emit storagePathStatusChanged();
}

QString DeclarativeSettings::photoCapturePath(const QString &extension)
{
    verifyCapturePrefix();

    for (;;) {
        const int counter = m_counter.value().toInt() + 1;
        m_counter.set(counter);

        const QString path = photoDirectory()
                    + QLatin1Char('/')
                    + m_prefix
                    + QString(QStringLiteral("%1.")).arg(counter, 3, 10, QLatin1Char('0'))
                    + extension;
        if (!QFile::exists(path))
            return path;
    }
}

QString DeclarativeSettings::videoCapturePath(const QString &extension)
{
    verifyCapturePrefix();

    for (;;) {
        const int counter = m_counter.value().toInt() + 1;
        m_counter.set(counter);

        const QString path = videoDirectory()
                  + QLatin1String("/.recording/")
                  + m_prefix
                  + QString(QStringLiteral("%1.")).arg(counter, 3, 10, QLatin1Char('0'))
                + extension;

        if (!QFile::exists(path))
            return path;
    }
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

static int counterStartValue(const QString &directory, const QString &prefix, int maximum = 0)
{
    QDirIterator iterator(directory, QStringList() << prefix + QLatin1Char('*'), QDir::Files);
    while (iterator.hasNext()) {
        iterator.next();
        const QString fileName = iterator.fileName();
        const int length = fileName.indexOf(QLatin1Char('.'), prefix.length()) - prefix.length();
        maximum = qMax(maximum, fileName.mid(prefix.length(), length).toInt());
    }
    return maximum;
}

void DeclarativeSettings::verifyCapturePrefix()
{
    const QDate currentDate = QDate::currentDate();
    if (m_prefixDate != currentDate) {
        m_prefixDate = currentDate;
        m_prefix = QLocale::c().toString(currentDate, QLatin1String("yyyyMMdd_"));
        int counter = counterStartValue(photoDirectory(), m_prefix);
        counter = counterStartValue(videoDirectory(), m_prefix, counter);

        m_counter.set(counter);
        m_counterDate.set(m_prefixDate.toString(Qt::ISODate));
    }
}
