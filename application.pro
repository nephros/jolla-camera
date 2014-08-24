TEMPLATE = app
TARGET = jolla-camera
TARGETPATH = /usr/bin

QT += qml quick
CONFIG += link_pkgconfig

SOURCES += camera.cpp

OTHER_FILES += \
        camera.qml \
        settings.qml \
        cover \
        pages \
        dconf/*.qml \
        dconf/jolla-camera.txt \
        dconf/mako-camera.txt

target.path = $$TARGETPATH

desktop.path = /usr/share/applications
desktop.files = \
            jolla-camera.desktop \
            jolla-camera-viewfinder.desktop

DEPLOYMENT_PATH = /usr/share/$$TARGET
DEFINES *= DEPLOYMENT_PATH=\"\\\"\"$${DEPLOYMENT_PATH}/\"\\\"\"
qml.path = $$DEPLOYMENT_PATH
qml.files = *.qml cover pages gconf

service.files = com.jolla.camera.service
service.path  = /usr/share/dbus-1/services

enablehints.files = enable-camera-hints
enablehints.path  = /usr/lib/oneshot.d

schema.files = dconf/mako-camera.txt
schema.path  = /etc/dconf/db/vendor.d/

presets.files = presets/*.prs
presets.path = /usr/share/jolla-camera/presets

DEFINES *= JOLLA_CAMERA_GSTREAMER_PRESET_DIRECTORY=\"\\\"\"$${presets.path}/\"\\\"\"

INSTALLS += target desktop qml service schema presets enablehints

PKGCONFIG += gstreamer-0.10

packagesExist(qdeclarative5-boostable) {
    message("Building with qdeclarative-boostable support")
    DEFINES += HAS_BOOSTER
    PKGCONFIG += qdeclarative5-boostable
} else {
    warning("qdeclarative-boostable not available; startup times will be slower")
}

