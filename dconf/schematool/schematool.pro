TEMPLATE = app
TARGET = dconf-schema-tool

QT += dbus qml multimedia

DEFINES += DESKTOP

HEADERS += \
        declarativedconfschema.h

SOURCES += \
        declarativedconfschema.cpp \
        main.cpp

MODULENAME = com/jolla/camera/settings
TARGETPATH = $$[QT_INSTALL_QML]/$$MODULENAME
