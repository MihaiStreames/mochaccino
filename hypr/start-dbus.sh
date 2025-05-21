#!/bin/bash

# Start D-Bus if not running
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax)
    echo "D-Bus session started: $DBUS_SESSION_BUS_ADDRESS"
fi

# Export variables to the environment
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID

# Start GNOME Keyring daemon
eval $(gnome-keyring-daemon --start --components=secrets,ssh)
export GNOME_KEYRING_CONTROL SSH_AUTH_SOCK

# Print status for debugging
echo "DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS"
echo "GNOME_KEYRING_CONTROL=$GNOME_KEYRING_CONTROL"
echo "SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
