
#include "declarativesettings.h"

#include <QDebug>
#include <QDir>
#include <QDirIterator>
#include <QEvent>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QSettings>
#include <QStandardPaths>

#include <dirent.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>

#include <sys/inotify.h>

DeclarativeSettings::DeclarativeSettings(QObject *parent)
    : QSocketNotifier(inotify_init(), Read, parent)
    , m_counter(QLatin1String("/apps/jolla-camera/captureCounter"))
    , m_counterDate(QLatin1String("/apps/jolla-camera/captureCounterDate"))
    , m_locationWatch(-1)
    , m_locationEnabled(false)
{
    QDir(photoDirectory()).mkpath(QLatin1String("."));
    QDir(videoDirectory()).mkpath(QLatin1String(".recording"));

    m_prefixDate = QDate::fromString(m_counterDate.value().toString(), Qt::ISODate);
    m_prefix = m_prefixDate.toString(QLatin1String("yyyyMMdd_"));

    updateLocation();

    const int fd = socket();
    if (fd >= 0) {
        m_locationWatch = inotify_add_watch(fd, "/etc/location/location.conf", IN_MODIFY);
    }
}

DeclarativeSettings::~DeclarativeSettings()
{
    close(socket());
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
    return QStandardPaths::writableLocation(QStandardPaths::PicturesLocation) + QLatin1String("/Camera");

}

QString DeclarativeSettings::videoDirectory() const
{
    return QStandardPaths::writableLocation(QStandardPaths::MoviesLocation) + QLatin1String("/Camera");
}

QString DeclarativeSettings::photoCapturePath(const QString &extension)
{
    verifyCapturePrefix();

    const int counter = m_counter.value().toInt() + 1;
    m_counter.set(counter);

    return photoDirectory()
                + QLatin1Char('/')
                + m_prefix
                + QString(QStringLiteral("%1.")).arg(counter, 3, 10, QLatin1Char('0'))
                + extension;
}

QString DeclarativeSettings::videoCapturePath(const QString &extension)
{
    verifyCapturePrefix();

    const int counter = m_counter.value().toInt() + 1;
    m_counter.set(counter);

    return videoDirectory()
                + QLatin1String("/.recording/")
                + m_prefix
                + QString(QStringLiteral("%1.")).arg(counter, 3, 10, QLatin1Char('0'))
                + extension;
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

bool DeclarativeSettings::event(QEvent *event)
{
    if (event->type() != QEvent::SockAct) {
        return QSocketNotifier::event(event);
    }

#define BUFF_SIZE ((sizeof(struct inotify_event)+FILENAME_MAX)*1024)

    bool locationChanged = false;

    char buff[BUFF_SIZE] = {0};
    ssize_t length = read (socket(), buff, BUFF_SIZE);
    struct inotify_event *pevent = 0;
    for (ssize_t i = 0; i < length; i += sizeof(struct inotify_event) + pevent->len) {
        pevent = (struct inotify_event *)&buff[i];

        if (pevent->wd == m_locationWatch) {
            locationChanged = true;
        }
    }


    if (locationChanged) {
        updateLocation();
    }

    return true;
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
        m_prefix = currentDate.toString(QLatin1String("yyyyMMdd_"));
        int counter = counterStartValue(photoDirectory(), m_prefix);
        counter = counterStartValue(videoDirectory(), m_prefix, counter);

        m_counter.set(counter);
        m_counterDate.set(m_prefixDate.toString(Qt::ISODate));
    }
}
