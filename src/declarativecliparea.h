
#ifndef DECLARATIVECLIPAREA_H
#define DECLARATIVECLIPAREA_H

#include <QDeclarativeItem>

class DeclarativeClipArea : public QDeclarativeItem
{
    Q_OBJECT
public:
    DeclarativeClipArea(QDeclarativeItem *parent = 0);
    ~DeclarativeClipArea();

    QPainterPath shape() const;
};

#endif
