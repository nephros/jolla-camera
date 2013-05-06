
INCLUDEPATH += $$PWD

CONFIG += link_pkgconfig
packagesExist(gconf-2.0) {
    PKGCONFIG += gobject-2.0 gconf-2.0
} else {
    DEFINES += GCONF_DISABLED
}

SOURCES += \
        $$PWD/declarativecameralocks.cpp \
        $$PWD/declarativecompassaction.cpp \
        $$PWD/declarativegconfschema.cpp \
        $$PWD/declarativegconfsettings.cpp \
        $$PWD/declarativesettings.cpp \

HEADERS += \
        $$PWD/declarativecameralocks.h \
        $$PWD/declarativecompassaction.h \
        $$PWD/declarativegconfschema.h \
        $$PWD/declarativegconfsettings.h \
        $$PWD/declarativesettings.h \

equals(QT_MAJOR_VERSION, 4) {
    SOURCES += \
            $$PWD/declarativecamera.cpp \
            $$PWD/declarativecameraviewport.cpp \
            $$PWD/declarativecliparea.cpp \
            $$PWD/declarativeexposure.cpp \
            $$PWD/declarativeflash.cpp \
            $$PWD/declarativefocus.cpp

    HEADERS += \
            $$PWD/declarativecamera.h \
            $$PWD/declarativecameraviewport.h \
            $$PWD/declarativecliparea.h \
            $$PWD/declarativeexposure.h \
            $$PWD/declarativeflash.h \
            $$PWD/declarativefocus.h \
            $$PWD/declarativewhitebalance.h
}
