
#ifndef DECLARATIVECAMERAVIEWPORT_H
#define DECLARATIVECAMERAVIEWPORT_H

#include <QDeclarativeItem>
#include <QGraphicsVideoItem>

class DeclarativeCamera;

class DeclarativeCameraViewport : public QDeclarativeItem
{
    Q_OBJECT
    Q_PROPERTY(DeclarativeCamera *camera READ camera WRITE setCamera NOTIFY cameraChanged)
public:
    DeclarativeCameraViewport(QDeclarativeItem *parent = 0);
    ~DeclarativeCameraViewport();

    DeclarativeCamera *camera() const;
    void setCamera(DeclarativeCamera *camera);

Q_SIGNALS:
    void cameraChanged();

protected:
    void geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry);

private:
    QGraphicsVideoItem m_videoItem;
    DeclarativeCamera *m_camera;
};

#endif
