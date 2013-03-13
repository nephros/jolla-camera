
#ifndef DECLARATIVEWHITEBALANCE_H
#define DECLARATIVEWHITEBALANCE_H

#include <QCameraImageProcessing>

class DeclarativeWhiteBalance : public QObject
{
    Q_OBJECT
    Q_ENUMS(Mode)
public:
    enum Mode
    {
        Auto            = QCameraImageProcessing::WhiteBalanceAuto,
        Sunlight        = QCameraImageProcessing::WhiteBalanceSunlight,
        Cloudy          = QCameraImageProcessing::WhiteBalanceCloudy,
        Shade           = QCameraImageProcessing::WhiteBalanceShade,
        Tungsten        = QCameraImageProcessing::WhiteBalanceTungsten,
        Fluorescent     = QCameraImageProcessing::WhiteBalanceFluorescent,
        Incandescent    = QCameraImageProcessing::WhiteBalanceIncandescent,
        Flash           = QCameraImageProcessing::WhiteBalanceFlash,
        Sunset          = QCameraImageProcessing::WhiteBalanceSunset
    };
};

#endif
