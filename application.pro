TEMPLATE = app
TARGET = jolla-camera
TARGETPATH = /usr/bin

QT += qml quick
CONFIG += link_pkgconfig

PKGCONFIG += \
    sailfishsilica

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
qml.path = $$DEPLOYMENT_PATH
qml.files = *.qml cover pages gconf

service.files = com.jolla.camera.service
service.path  = /usr/share/dbus-1/services

oneshot.files = camera-enable-hints \
        camera-remove-deprecated-dconfkeys
oneshot.path  = /usr/lib/oneshot.d

schema.files = dconf/jolla-camera.txt
schema.path  = /etc/dconf/db/vendor.d/

INSTALLS += target desktop qml service schema oneshot
