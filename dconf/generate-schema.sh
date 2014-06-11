#!/bin/bash

if [ $# -eq 2 ]; then
    echo Please kill me: qmlscene doesn\'t handle Qt.quit
    qmlscene $1 2>&1 | sed -u 's/qml: //' > $2
else
    echo Usage: generate-schema.sh QML_SCHEMA DCONF_DEFAULTS
fi
