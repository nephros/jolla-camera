
#include "declarativecameraextensions.h"

#include <QGuiApplication>
#include <QQmlInfo>

#include <QtDebug>

#include <QQuickWindow>
#include <qpa/qplatformnativeinterface.h>

DeclarativeCameraExtensions::DeclarativeCameraExtensions(QObject *parent)
    : QObject(parent)
{
}

DeclarativeCameraExtensions::~DeclarativeCameraExtensions()
{
}

void DeclarativeCameraExtensions::disableNotifications(QQuickItem *item, bool disable)
{
    if (QWindow *window = item ? item->window() : 0) {
        QGuiApplication::platformNativeInterface()->setWindowProperty(
                    window->handle(), QLatin1String("NOTIFICATION_PREVIEWS_DISABLED"),
                    QVariant(disable ? 3 : 0));
    }
}
