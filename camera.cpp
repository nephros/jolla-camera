
#include <QDir>
#include <QTranslator>
#include <QLocale>

#include <QGuiApplication>
#include <QQmlEngine>
#include <QQmlContext>
#include <QQuickItem>
#include <QQuickView>
#include <QQmlComponent>
#include <QQmlIncubator>

#include <silicascreen.h>

#include <QElapsedTimer>

#include <QSGSimpleRectNode>
#include <QSGSimpleTextureNode>

namespace {

QElapsedTimer timer;
qint64 appTime;
qint64 windowTime;
qint64 showTime;
qint64 engineTime;
qint64 componentTime;
qint64 createTime;

class SplashNode : public QSGNode
{
public:
    SplashNode()
    {
        appendChildNode(&m_rectNode);
        appendChildNode(&m_iconNode);
    }

    void update(QSGTexture *texture, const QSize &windowSize)
    {
        m_rectNode.setRect(QRect(0, 0, windowSize.width(), windowSize.height()));
        m_rectNode.setColor(Qt::black);

        const QSize textureSize = texture->textureSize();

        m_iconNode.setTexture(texture);
        m_iconNode.setRect(
                    (windowSize.width() - textureSize.width()) / 2,
                    (windowSize.height() - textureSize.height()) / 2,
                    textureSize.width(),
                    textureSize.height());
        m_iconNode.setOwnsTexture(true);
    }

private:
    QSGSimpleRectNode m_rectNode;
    QSGSimpleTextureNode m_iconNode;
};

class SplashItem : public QQuickItem
{
public:
    explicit SplashItem(const QString &imagePath, QQuickItem *parent)
        : QQuickItem(parent)
        , m_image(imagePath)
    {
        setFlag(ItemHasContents);
        setZ(1000);
    }

protected:
    QSGNode *updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *) override
    {
        SplashNode *node = static_cast<SplashNode *>(oldNode);

        if (!node) {
            node = new SplashNode;
        }

        QQuickWindow * const window = this->window();

        node->update(window->createTextureFromImage(m_image), window->size());

        return node;
    }

private:
    QImage m_image;
};


class Incubator : public QQmlIncubator
{
public:
    explicit Incubator(QQuickWindow *window, SplashItem *splash)
//        : QQmlIncubator(Asynchronous)
        : QQmlIncubator(Synchronous)
        , m_window(window)
        , m_splash(splash)
    {
    }

protected:
    void statusChanged(Status status) override
    {
        switch (status) {
        case QQmlIncubator::Null:
        case QQmlIncubator::Loading:
            break;
        case QQmlIncubator::Ready:
            createTime = timer.restart();

            qDebug() << "Go time. App" << appTime << "Window" << windowTime << "Show" << showTime << "Engine" << engineTime << "Component" << componentTime << "Create" << createTime;

            m_splash->setParentItem(nullptr);

            break;
        case QQmlIncubator::Error:
            qWarning() << "Unable to read main qml file";
            QCoreApplication::exit(EXIT_FAILURE);
        }
    }

    void setInitialState(QObject *object) override
    {
        if (QQuickItem *item = qobject_cast<QQuickItem *>(object)) {
            item->setParent(m_window->contentItem());
            item->setParentItem(m_window->contentItem());
            item->setWidth(m_window->width());
            item->setHeight(m_window->height());

//            if (isDesktop) {
//                item->setProperty("_desktop", true);
//            }


        } else {
            forceCompletion();

            qWarning() << "Root object is not an item";

            QCoreApplication::exit(EXIT_FAILURE);
        }
    }

private:
    QQuickWindow * const m_window;
    SplashItem * const m_splash;
};

}

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    timer.start();

    QGuiApplication app(argc, argv);

    appTime = timer.restart();

    bool isDesktop = app.arguments().contains("-desktop");

    QQuickWindow::setDefaultAlphaBuffer(true);
    QScopedPointer<QQuickWindow> window(new QQuickWindow);


    SplashItem * const splashItem = new SplashItem("/usr/share/themes/sailfish-default/meegotouch/z1.25/icons/icon-launcher-camera.png", window->contentItem());

    windowTime = timer.restart();

    //% "Camera"
    QT_TRID_NOOP("jolla-camera-ap-name");
    window->setTitle(qtTrId("jolla-camera-ap-name"));

    window->resize(Silica::Screen::instance()->width(), Silica::Screen::instance()->height());

    if (isDesktop) {
        window->show();
    } else {
        window->showFullScreen();
    }

    showTime = timer.restart();

    QString path;
    if (isDesktop) {
        path = app.applicationDirPath() + QDir::separator();
    } else {
        path = QString(DEPLOYMENT_PATH);
    }

    QQmlEngine engine;
    engine.setIncubationController(window->incubationController());
    engine.setBaseUrl(QUrl::fromLocalFile(path));

    engineTime = timer.restart();

    QQmlComponent component(&engine);
    Incubator incubator(window.data(), splashItem);

    QObject::connect(&component, &QQmlComponent::statusChanged, &engine, [&] {
        switch (component.status()) {
        case QQmlComponent::Null:
        case QQmlComponent::Loading:
            break;
        case QQmlComponent::Ready:
            componentTime = timer.restart();

            component.create(incubator);
            break;
        case QQmlComponent::Error:
            qWarning() << "Unable to read main qml file";
            qWarning() << component.errorString();

            QCoreApplication::exit(EXIT_FAILURE);
            break;
        }
    });

    component.loadUrl(path + QLatin1String("camera.qml"), QQmlComponent::Asynchronous);
//    component.loadUrl(path + QLatin1String("camera.qml"), QQmlComponent::PreferSynchronous);

    const int result = app.exec();

    window.reset();

    return result;
}






