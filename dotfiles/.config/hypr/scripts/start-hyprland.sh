#!/usr/bin/env bash
set -euo pipefail

# turnstile's dinit user instance normally owns this bus
# outside a turnstile session start one at the same
# fixed address so it matches what conf/env.lua forces

bus="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/bus"

if [[ ! -S "$bus" ]]; then
  dbus-daemon --session --address="unix:path=$bus" --fork
fi

export DBUS_SESSION_BUS_ADDRESS="unix:path=$bus"

# official launcher, adds the crash watchdog over a bare `exec Hyprland`
exec start-hyprland
