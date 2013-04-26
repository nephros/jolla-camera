#ifndef DECLARATIVECOMPASSBUTTON_H
#define DECLARATIVECOMPASSBUTTON_H

#include <QObject>
#include <QUrl>

class DeclarativeCompassAction : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl smallIcon READ smallIcon WRITE setSmallIcon NOTIFY smallIconChanged)
    Q_PROPERTY(QUrl largeIcon READ largeIcon WRITE setLargeIcon NOTIFY largeIconChanged)
    Q_PROPERTY(bool enabled READ isEnabled WRITE setEnabled NOTIFY enabledChanged)
public:
    DeclarativeCompassAction(QObject *parent = 0);
    ~DeclarativeCompassAction();

    QUrl smallIcon() const;
    void setSmallIcon(const QUrl &icon);

    QUrl largeIcon() const;
    void setLargeIcon(const QUrl &icon);

    bool isEnabled() const;
    void setEnabled(bool enabled);

signals:
    void activated();
    void smallIconChanged();
    void largeIconChanged();
    void enabledChanged();

private:
    QUrl m_smallIcon;
    QUrl m_largeIcon;
    bool m_enabled;
};

#endif
