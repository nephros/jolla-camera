
MODULENAME = com/jolla/camera
TARGET = jollacameraplugin

include (../../../imports.pri)

CAMERA_SOURCE_PATH = $$PWD/../../../../../src
CAMERA_QML_PATH = $$PWD/../../../../../pages
INCLUDEPATH += $$CAMERA_SOURCE_PATH

SOURCES += \
        camera.cpp \
        $$CAMERA_SOURCE_PATH/capturemodel.cpp \
        $$CAMERA_SOURCE_PATH/declarativecompassaction.cpp \

HEADERS += \
        $$CAMERA_SOURCE_PATH/capturemodel.h \
        $$CAMERA_SOURCE_PATH/declarativecompassaction.h \


import.files = \
        $$CAMERA_QML_PATH\compass\Compass.qml \
        $$CAMERA_QML_PATH\compass\CompassMenu.qml \
        $$CAMERA_QML_PATH\compass\CompassMenuItem.qml \
        qmldir
import.path = $$TARGETPATH
INSTALLS += import
