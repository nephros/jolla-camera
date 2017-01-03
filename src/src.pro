TEMPLATE = lib
TARGET  = jollacameraplugin
TARGET = $$qtLibraryTarget($$TARGET)

MODULENAME = com/jolla/camera
TARGETPATH = $$[QT_INSTALL_QML]/$$MODULENAME

QT += gui-private qml quick multimedia
CONFIG += plugin link_pkgconfig c++11

PKGCONFIG += mlite5 systemsettings

SOURCES += \
        cameraplugin.cpp \
        capturemodel.cpp \
        declarativecameraextensions.cpp \
        declarativesettings.cpp

HEADERS += \
        capturemodel.h \
        declarativecameraextensions.h \
        declarativesettings.h

DEFINES += \
        DEPLOYMENT_PATH=\"\\\"\"$${TARGETPATH}/\"\\\"\"

import.files = \
        capture \
        qmldir \
        settings \
        settings.qml

import.path = $$TARGETPATH
target.path = $$TARGETPATH

INSTALLS += target import

OTHER_FILES = \
        capture/*.qml \
        settings/*.qml \
        settings.qml
