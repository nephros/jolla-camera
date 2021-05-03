/****************************************************************************************
**
** Copyright (C) 2021 Jolla Ltd.
** All rights reserved.
**
** License: Proprietary
**
****************************************************************************************/

#include <QGuiApplication>
#include <QDir>
#include <QQmlEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQuickView>
#include <QQuickItem>
#include <QScreen>
#include <QDebug>

#ifdef HAS_BOOSTER
#include <MDeclarativeCache>
#endif

Q_DECL_EXPORT int main(int argc, char *argv[])
{
#ifdef HAS_BOOSTER
    QScopedPointer<QGuiApplication> app(MDeclarativeCache::qApplication(argc, argv));
    QScopedPointer<QQuickView> view(MDeclarativeCache::qQuickView());
#else
    QScopedPointer<QGuiApplication> app(new QGuiApplication(argc, argv));
    QScopedPointer<QQuickView> view(new QQuickView);
#endif

#ifdef DESKTOP
    bool isDesktop = true;
#else
    bool isDesktop = app->arguments().contains("-desktop");
#endif

    QString path;
    if (isDesktop) {
        path = app->applicationDirPath() + QDir::separator();
    } else {
        path = QString(DEPLOYMENT_PATH);
    }

    view->setSource(path + QLatin1String("cameratestapp.qml"));

    if (view->status() == QQuickView::Error) {
        qWarning() << "Unable to read main qml file";
        return 1;
    }

    if (isDesktop) {
        view->setResizeMode(QQuickView::SizeRootObjectToView);

        if (app->arguments().contains("-openInSecondScreen")) {
            if (QScreen *secondScreen = QGuiApplication::screens().value(1))
                view->setPosition(secondScreen->geometry().topLeft() + QPoint(100, 100));
        }

        view->show();
    } else {
        view->showFullScreen();
    }

    return app->exec();
}

