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
        pages/*.qml \
        pages/capture/*.qml \
        pages/gallery/*.qml \
        pages/settings/*.qml \
        dconf/*.qml \
        dconf/jolla-camera.txt

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

enablehints.files = camera-enable-hints
enablehints.path  = /usr/lib/oneshot.d

schema.files = dconf/jolla-camera.txt
schema.path  = /etc/dconf/db/vendor.d/

notification_types.path  = /usr/share/lipstick/notificationcategories
notification_types.files = x-jolla.settings.camera.conf

INSTALLS += target desktop qml service schema enablehints notification_types

packagesExist(qdeclarative5-boostable) {
    message("Building with qdeclarative-boostable support")
    DEFINES += HAS_BOOSTER
    PKGCONFIG += qdeclarative5-boostable
} else {
    warning("qdeclarative-boostable not available; startup times will be slower")
}

