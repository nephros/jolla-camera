
MODULENAME = com/jolla/camera
TARGET = jollacameraplugin

include (../../../imports.pri)

CAMERA_SOURCE_PATH = $$PWD/../../../../../src
CAMERA_QML_PATH = $$PWD/../../../../../pages
INCLUDEPATH += $$CAMERA_SOURCE_PATH

SOURCES += \
        camera.cpp \
        $$CAMERA_SOURCE_PATH/capturemodel.cpp \

HEADERS += \
        $$CAMERA_SOURCE_PATH/capturemodel.h \


import.files = \
        qmldir
import.path = $$TARGETPATH
INSTALLS += import
