TEMPLATE = aux
TARGET  = jollacamerasettingsplugin
TARGET = $$qtLibraryTarget($$TARGET)

CONFIG += \
    sailfish_install_qml

SAILFISH_QML_INSTALL = /usr/share/jolla-settings/pages/jolla-camera
QML_FILES = \
        ResolutionComboBox.qml \
        ResolutionComboItem.qml \
        SettingsPage.qml \

plugin_entry.path = /usr/share/jolla-settings/entries
plugin_entry.files = jolla-camera.json

DEFINES += \
        DEPLOYMENT_PATH=\"\\\"\"$${TARGETPATH}/\"\\\"\"

OTHER_FILES += *.qml

INSTALLS += plugin_entry
