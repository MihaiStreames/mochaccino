#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"
fi

alias claude-mem='bun "/home/sincos/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'
