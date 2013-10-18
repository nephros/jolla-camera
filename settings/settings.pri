
INCLUDEPATH += $$PWD

CONFIG += link_pkgconfig
packagesExist(gconf-2.0) {
    PKGCONFIG += gobject-2.0 gconf-2.0
} else {
    DEFINES += GCONF_DISABLED
}

PKGCONFIG += mlite5

HEADERS += \
        $$PWD/declarativesettings.h

SOURCES += \
        $$PWD/declarativesettings.cpp

DEFINES += \
        DEPLOYMENT_PATH=\"\\\"\"$${TARGETPATH}/\"\\\"\"
