
#include "declarativecompassaction.h"

DeclarativeCompassAction::DeclarativeCompassAction(QObject *parent)
    : QObject(parent)
    , m_enabled(true)
{
}

DeclarativeCompassAction::~DeclarativeCompassAction()
{
}

QUrl DeclarativeCompassAction::smallIcon() const
{
    return m_smallIcon;
}

void DeclarativeCompassAction::setSmallIcon(const QUrl &icon)
{
    if (m_smallIcon != icon) {
        m_smallIcon = icon;
        emit smallIconChanged();
    }
}

QUrl DeclarativeCompassAction::largeIcon() const
{
    return m_largeIcon;
}

void DeclarativeCompassAction::setLargeIcon(const QUrl &icon)
{
    if (m_largeIcon != icon) {
        m_largeIcon = icon;
        emit largeIconChanged();
    }
}

bool DeclarativeCompassAction::isEnabled() const
{
    return m_enabled;
}

void DeclarativeCompassAction::setEnabled(bool enabled)
{
    if (m_enabled != enabled) {
        m_enabled = enabled;
        emit enabledChanged();
    }
}
