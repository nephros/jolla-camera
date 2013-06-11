TEMPLATE = app
TARGET = gconf-schema-tool

QT += dbus qml multimedia

DEFINES += DESKTOP

HEADERS += \
        declarativegconfschema.h

SOURCES += \
        declarativegconfschema.cpp \
        main.cpp

include (../../src/src.pri)
