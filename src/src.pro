TEMPLATE = lib
TARGET  = jollacameraplugin
TARGET = $$qtLibraryTarget($$TARGET)

MODULENAME = com/jolla/camera
TARGETPATH = $$[QT_INSTALL_QML]/$$MODULENAME

QT += gui-private qml quick multimedia multimedia-private
CONFIG += plugin link_pkgconfig

PKGCONFIG += mlite5

packagesExist(gconf-2.0) {
    PKGCONFIG += gobject-2.0 gconf-2.0
} else {
    DEFINES += GCONF_DISABLED
}

SOURCES += \
        cameraplugin.cpp \
        capturemodel.cpp \
        declarativecameraextensions.cpp \
        declarativecameralocks.cpp \
        declarativegconfsettings.cpp \
        declarativesettings.cpp

HEADERS += \
        capturemodel.h \
        declarativecameraextensions.h \
        declarativecameralocks.h \
        declarativegconfsettings.h \
        declarativesettings.h

DEFINES += \
        DEPLOYMENT_PATH=\"\\\"\"$${TARGETPATH}/\"\\\"\"

import.files = \
        qmldir \
        settings.qml

import.path = $$TARGETPATH
target.path = $$TARGETPATH

INSTALLS += target import
