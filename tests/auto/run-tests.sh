#!/bin/sh

# SPDX-FileCopyrightText: 2013 - 2021 Jolla Ltd.
# SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
#
# SPDX-License-Identifier: BSD-3-Clause

# Create a temporary DBus session to isolate us from the normal environment.
export `dbus-launch`

qmltestrunner $@
exit_code=$?

kill $DBUS_SESSION_BUS_PID

exit $exit_code
