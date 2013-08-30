
#include "declarativesettings.h"
#include "declarativecameraextensions.h"

#include <QCameraFocus>
#include <QCameraExposure>
#include <QCameraImageProcessing>
#include <QDir>
#include <QDirIterator>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QStandardPaths>

DeclarativeSettings::DeclarativeSettings(QObject *parent)
    : QObject(parent)
    , m_counter(0)
{
    QDir(photoDirectory()).mkpath(QLatin1String("."));
    QDir(videoDirectory()).mkpath(QLatin1String("."));
}

DeclarativeSettings::~DeclarativeSettings()
{
}

QObject *DeclarativeSettings::factory(QQmlEngine *engine, QJSEngine *)
{
    const QUrl source = engine->baseUrl().resolved(QUrl(QStringLiteral("pages/settings/settings.qml")));
    QQmlComponent component(engine, source);
    if (component.isReady()) {
        return component.create();
    } else {
        qWarning() << "Failed to instantiate Settings";
        qWarning() << component.errors();
        return 0;
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
    return photoDirectory()
                + QLatin1Char('/')
                + m_prefix
                + QString(QStringLiteral("%1.")).arg(++m_counter, 3, 10, QLatin1Char('0'))
                + extension;
}

QString DeclarativeSettings::videoCapturePath(const QString &extension)
{
    verifyCapturePrefix();
    return videoDirectory()
                + QLatin1Char('/')
                + m_prefix
                + QString(QStringLiteral("%1.")).arg(++m_counter, 3, 10, QLatin1Char('0'))
                + extension;
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
        m_counter = counterStartValue(photoDirectory(), m_prefix);
        m_counter = counterStartValue(videoDirectory(), m_prefix, m_counter);
    }
}


