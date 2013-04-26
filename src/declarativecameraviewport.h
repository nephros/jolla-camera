
#ifndef DECLARATIVECAMERAVIEWPORT_H
#define DECLARATIVECAMERAVIEWPORT_H

#include <QDeclarativeItem>
#include <QGraphicsVideoItem>

class DeclarativeCamera;

class DeclarativeCameraViewport : public QDeclarativeItem
{
    Q_OBJECT
    Q_PROPERTY(DeclarativeCamera *source READ camera WRITE setCamera NOTIFY cameraChanged)
    Q_PROPERTY(FillMode fillMode READ fillMode WRITE setFillMode NOTIFY fillModeChanged)
    Q_ENUMS(FillMode)
public:
    enum FillMode {
        PreserveAspectFit
    };

    DeclarativeCameraViewport(QDeclarativeItem *parent = 0);
    ~DeclarativeCameraViewport();

    DeclarativeCamera *camera() const;
    void setCamera(DeclarativeCamera *camera);

    FillMode fillMode() const;
    void setFillMode(FillMode mode);

Q_SIGNALS:
    void cameraChanged();
    void fillModeChanged();

protected:
    void geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry);

private:
    QGraphicsVideoItem m_videoItem;
    DeclarativeCamera *m_camera;
};

#endif
