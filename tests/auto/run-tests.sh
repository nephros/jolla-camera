#!/bin/sh

# Create a temporary DBus session to isolate us from the normal environment.
export `dbus-launch`

qmltestrunner $@
exit_code=$?

kill $DBUS_SESSION_BUS_PID

exit $exit_code
