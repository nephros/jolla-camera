TEMPLATE = lib
TARGET  = jollacamerasettingsplugin
TARGET = $$qtLibraryTarget($$TARGET)

MODULENAME = com/jolla/camera/settings
TARGETPATH = $$[QT_INSTALL_QML]/$$MODULENAME

QT += qml gui
CONFIG += plugin link_pkgconfig

include (settings.pri)

import.files = \
        qmldir \
        settings.qml

import.path = $$TARGETPATH
target.path = $$TARGETPATH

settingsqml.path = /usr/share/jolla-settings/pages/jolla-camera
settingsqml.files = \
        ResolutionComboBox.qml \
        ResolutionComboItem.qml \
        SettingsPage.qml \

plugin_entry.path = /usr/share/jolla-settings/entries
plugin_entry.files = jolla-camera.json

DEFINES += \
        DEPLOYMENT_PATH=\"\\\"\"$${TARGETPATH}/\"\\\"\"

OTHER_FILES += *.qml

HEADERS += \
        declarativegconfsettings.h

SOURCES += \
        declarativegconfsettings.cpp \
        settingsplugin.cpp

TS_FILE = $$OUT_PWD/jolla-camera_settings.ts
EE_QM = $$OUT_PWD/jolla-camera_settings_eng_en.qm

translations.commands += lupdate $$PWD -ts $$TS_FILE
translations.depends = $$PWD/*.qml
translations.CONFIG += no_check_exist no_link
translations.output = $$TS_FILE
translations.input = .

translations_install.files = $$TS_FILE
translations_install.path = /usr/share/translations/source
translations_install.CONFIG += no_check_exist


# should add -markuntranslated "-" when proper translations are in place (or for testing)
engineering_english.commands += lrelease -idbased $$TS_FILE -qm $$EE_QM
engineering_english.CONFIG += no_check_exist no_link
engineering_english.depends = translations
engineering_english.input = $$TS_FILE
engineering_english.output = $$EE_QM

engineering_english_install.path = /usr/share/translations
engineering_english_install.files = $$EE_QM
engineering_english_install.CONFIG += no_check_exist

QMAKE_EXTRA_TARGETS += translations engineering_english

PRE_TARGETDEPS += translations engineering_english

INSTALLS += target import translations_install engineering_english_install settingsqml plugin_entry
