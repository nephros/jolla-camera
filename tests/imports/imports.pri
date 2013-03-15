TEMPLATE = lib

QT += declarative

TARGET = $$qtLibraryTarget($$TARGET)
TARGETPATH = /opt/tests/jolla-camera/imports/$$MODULENAME

target.path = $$TARGETPATH
INSTALLS += target
