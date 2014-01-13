TEMPLATE = subdirs

OTHER_FILES += auto/*

auto.files = auto/*
auto.path = /opt/tests/jolla-camera/auto

definition.files = test-definition/tests.xml
definition.path = /opt/tests/jolla-camera/test-definition

INSTALLS += auto definition
