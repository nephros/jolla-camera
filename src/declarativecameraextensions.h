
#ifndef DECLARATIVECAMERAEXTENSIONS_H
#define DECLARATIVECAMERAEXTENSIONS_H

#include <QQuickItem>

class DeclarativeCameraExtensions : public QObject
{
    Q_OBJECT
public:
    DeclarativeCameraExtensions(QObject *parent = 0);
    ~DeclarativeCameraExtensions();

    Q_INVOKABLE void disableNotifications(QQuickItem *item, bool disable);

private:
};

#endif
