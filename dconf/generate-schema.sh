#!/bin/bash

# SPDX-FileCopyrightText: 2014 Jolla Ltd.
# SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
#
# SPDX-License-Identifier: BSD-3-Clause

if [ $# -eq 2 ]; then
    echo Please kill me: qmlscene doesn\'t handle Qt.quit
    qmlscene $1 2>&1 | sed -u 's/qml: //' > $2
else
    echo Usage: generate-schema.sh QML_SCHEMA DCONF_DEFAULTS
fi
