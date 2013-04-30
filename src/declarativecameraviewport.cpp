#include "declarativecameraviewport.h"

#include "declarativecamera.h"

DeclarativeCameraViewport::DeclarativeCameraViewport(QDeclarativeItem *parent)
    : QDeclarativeItem(parent)
    , m_camera(0)
{
    m_videoItem.setParentItem(this);
}

DeclarativeCameraViewport::~DeclarativeCameraViewport()
{
}

DeclarativeCamera *DeclarativeCameraViewport::camera() const
{
    return m_camera;
}

void DeclarativeCameraViewport::setCamera(DeclarativeCamera *camera)
{
    if (m_camera != camera) {
        if (m_camera)
            m_camera->camera()->setViewfinder(static_cast<QGraphicsVideoItem *>(0));
        m_camera = camera;
        if (m_camera)
            m_camera->camera()->setViewfinder(&m_videoItem);
        emit cameraChanged();
    }
}

DeclarativeCameraViewport::FillMode DeclarativeCameraViewport::fillMode() const
{
    return PreserveAspectFit;
}

void DeclarativeCameraViewport::setFillMode(FillMode)
{
}

void DeclarativeCameraViewport::geometryChanged(const QRectF &newGeometry, const QRectF &)
{
    m_videoItem.setSize(newGeometry.size());
}
