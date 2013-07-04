TEMPLATE = app
TARGET = gconf-schema-tool

QT += declarative

equals(QT_MAJOR_VERSION, 5) {
    QT += dbus qml quick multimedia
} else {
    QT += dbus declarative

    CONFIG += link_pkgconfig mobility

    MOBILITY += multimedia
}

DEFINES += DESKTOP

HEADERS += \
        declarativegconfschema.h

SOURCES += \
        declarativegconfschema.cpp \
        main.cpp

include (../../src/src.pri)
