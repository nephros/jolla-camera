TEMPLATE = app
TARGET = jolla-camera
TARGETPATH = /usr/bin

QT += qml quick
CONFIG += \
    link_pkgconfig \
    sailfish_install_qml

SOURCES += camera.cpp

OTHER_FILES += \
        camera.qml \
        settings.qml \
        cover \
        pages \
        pages/*.qml \
        pages/gallery/*.qml \
        dconf/*.qml \
        dconf/jolla-camera.txt

target.path = $$TARGETPATH

desktop.path = /usr/share/applications
desktop.files = \
            jolla-camera.desktop \
            jolla-camera-lockscreen.desktop \
            jolla-camera-viewfinder.desktop

DEPLOYMENT_PATH = /usr/share/$$TARGET
DEFINES *= DEPLOYMENT_PATH=\"\\\"\"$${DEPLOYMENT_PATH}/\"\\\"\"

QML_FILES = \
    $$files(*.qml) \
    $$files(cover/*.qml, true) \
    $$files(pages/*.qml, true)

service.files = com.jolla.camera.service
service.path  = /usr/share/dbus-1/services

oneshot.files = camera-enable-hints \
        camera-remove-deprecated-dconfkeys
oneshot.path  = /usr/lib/oneshot.d

schema.files = dconf/jolla-camera.txt
schema.path  = /etc/dconf/db/vendor.d/

INSTALLS += target desktop service schema oneshot

packagesExist(qdeclarative5-boostable) {
    message("Building with qdeclarative-boostable support")
    DEFINES += HAS_BOOSTER
    PKGCONFIG += qdeclarative5-boostable
} else {
    warning("qdeclarative-boostable not available; startup times will be slower")
}
