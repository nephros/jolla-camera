
MODULENAME = com/jolla/camera
TARGET = jollacameraplugin

include (../../../imports.pri)

CAMERA_SOURCE_PATH = $$PWD/../../../../../src
INCLUDEPATH += $$CAMERA_SOURCE_PATH

SOURCES += \
        camera.cpp \
        $$CAMERA_SOURCE_PATH/declarativecompassaction.cpp \

HEADERS += \
        $$CAMERA_SOURCE_PATH/declarativecompassaction.h \


import.files = qmldir
import.path = $$TARGETPATH
INSTALLS += import
