TEMPLATE = aux
TARGET  = jollacamerasettingsplugin
TARGET = $$qtLibraryTarget($$TARGET)

settingsqml.path = /usr/share/jolla-settings/pages/jolla-camera
settingsqml.files = SettingsPage.qml

plugin_entry.path = /usr/share/jolla-settings/entries
plugin_entry.files = jolla-camera.json

DEFINES += \
        DEPLOYMENT_PATH=\"\\\"\"$${TARGETPATH}/\"\\\"\"

OTHER_FILES += *.qml

INSTALLS += settingsqml plugin_entry
