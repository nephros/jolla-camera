TARGET = cameratestapp
TARGETPATH = /usr/bin
target.path = $$TARGETPATH

DEPLOYMENT_PATH = /usr/share/$$TARGET
qml.files = *.qml pages cover
qml.path = $$DEPLOYMENT_PATH

desktop.files = cameratestapp.desktop
desktop.path = /usr/share/applications

include (../../common.pri)

QT += quick gui

contains(CONFIG, desktop) {
   DEFINES += DESKTOP
}

SOURCES += cameratestapp.cpp

QML_FILES = \
    $$files(*.qml, true)

!equals(OUT_PWD, $$PWD) {
    copy_qml.files = \
        $$QML_FILES
    copy_qml.path = $$OUT_PWD
    copy_qml.base = $$PWD

    COPIES += \
        copy_qml
}

OTHER_FILES += \
    *.qml \
    pages/*.qml \
    *.desktop

!contains(CONFIG, desktop) {
    INSTALLS += target qml desktop
}

DEFINES *= DEPLOYMENT_PATH=\"\\\"\"$${DEPLOYMENT_PATH}/\"\\\"\"

CONFIG += link_pkgconfig c++11
packagesExist(qdeclarative5-boostable) {
    message("Building with qdeclarative-boostable support")
    DEFINES += HAS_BOOSTER
    PKGCONFIG += qdeclarative5-boostable
} else {
    warning("qdeclarative-boostable not available; startup times will be slower")
}

LIBS += -L$$MODULE_BASE_OUTDIR/lib
