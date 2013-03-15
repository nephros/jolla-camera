
#include <qdeclarative.h>
#include <QDeclarativeExtensionPlugin>

class DeclarativeCamera : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Status status READ status WRITE setStatus NOTIFY statusChanged)
    Q_PROPERTY(CaptureMode captureMode READ captureMode WRITE setCaptureMode NOTIFY captureModeChanged)
    Q_ENUMS(Status)
    Q_ENUMS(CaptureMode)
public:
    enum Status
    {
        Null,
        Previewing,
        Capturing,
        Recording,
        Suspended,
        Error
    };

    enum CaptureMode
    {
        Still,
        Video
    };

    DeclarativeCamera(QObject *parent = 0)
        : QObject(parent), m_captureMode(Still), m_status(Previewing) {}
    ~DeclarativeCamera() {}

    Status status() const { return m_status; }
    void setStatus(Status status) { m_status = status; emit statusChanged(); }

    CaptureMode captureMode() const { return m_captureMode; }
    void setCaptureMode(CaptureMode mode) { m_captureMode = mode; emit captureModeChanged(); }

public Q_SLOTS:
    void capture() { m_status = Capturing; emit statusChanged(); }
    void record() { m_status = Recording; emit statusChanged(); }
    void stop() { m_status = Previewing; emit statusChanged(); }

Q_SIGNALS:
    void statusChanged();
    void captureModeChanged();

private:
    CaptureMode m_captureMode;
    Status m_status;
};

class Plugin : public QDeclarativeExtensionPlugin
{
    Q_OBJECT
public:
    void registerTypes(const char *)
    {
        qmlRegisterType<DeclarativeCamera>("com.jolla.camera", 1, 0, "Camera");
    }
};

Q_EXPORT_PLUGIN2(jollacameraplugin, Plugin);

#include "camera.moc"
