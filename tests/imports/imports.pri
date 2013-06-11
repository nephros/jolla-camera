TEMPLATE = lib

QT += qml quick

TARGET = $$qtLibraryTarget($$TARGET)
TARGETPATH = /opt/tests/jolla-camera/imports/$$MODULENAME

target.path = $$TARGETPATH
INSTALLS += target

