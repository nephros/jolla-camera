TEMPLATE = app
TARGET = gconf-schema-tool

QT += dbus qml multimedia

DEFINES += DESKTOP

HEADERS += \
        declarativegconfschema.h

SOURCES += \
        declarativegconfschema.cpp \
        main.cpp

MODULENAME = com/jolla/camera/settings
TARGETPATH = $$[QT_INSTALL_QML]/$$MODULENAME

include (../../settings/settings.pri)
