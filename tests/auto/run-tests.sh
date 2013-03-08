#!/bin/sh

# Create a temporary DBus session to isolate us from the normal environment.
export `dbus-launch`
export QML_IMPORT_PATH=$PWD/../imports

qmltestrunner $@
exit_code=$?

kill $DBUS_SESSION_BUS_PID

exit $exit_code
