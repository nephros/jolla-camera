
INCLUDEPATH += $$PWD

CONFIG += link_pkgconfig
packagesExist(gconf-2.0) {
    PKGCONFIG += gobject-2.0 gconf-2.0
} else {
    DEFINES += GCONF_DISABLED
}

SOURCES += \
        $$PWD/declarativecameraextensions.cpp \
        $$PWD/declarativecameralocks.cpp \
        $$PWD/declarativecompassaction.cpp \
        $$PWD/declarativegconfsettings.cpp \
        $$PWD/declarativesettings.cpp \

HEADERS += \
        $$PWD/declarativecameraextensions.h \
        $$PWD/declarativecameralocks.h \
        $$PWD/declarativecompassaction.h \
        $$PWD/declarativegconfsettings.h \
        $$PWD/declarativesettings.h \
