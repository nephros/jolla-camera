
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
    QPainterPath path;
    path.addEllipse(boundingRect());
    return path;
}
