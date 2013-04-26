
#include "declarativecliparea.h"

#include <QPainterPath>

DeclarativeClipArea::DeclarativeClipArea(QDeclarativeItem *parent)
    : QDeclarativeItem(parent)
{
    setFlag(ItemClipsChildrenToShape);
}

DeclarativeClipArea::~DeclarativeClipArea()
{
}

QPainterPath DeclarativeClipArea::shape() const
{
    const qreal radius = qMin(width(), height()) / 2;
    QPainterPath path;
    path.addRoundedRect(boundingRect(), radius, radius);
    return path;
}
