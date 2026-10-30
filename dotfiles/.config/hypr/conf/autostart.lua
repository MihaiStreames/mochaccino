-- https://wiki.hypr.land/configuring/core/autostart/

-- hyprland.start fires once per session, so this is the exec-once equivalent
hl.on("hyprland.start", function()
	--# STATUS BAR & NOTIFICATIONS #--
	hl.exec_cmd("waybar")
	hl.exec_cmd("dunst")

	--# SYS TRAY APPLETS #--
	hl.exec_cmd("nm-applet --indicator")
	hl.exec_cmd("blueman-applet")

	--# CLIPBOARD #--
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
	hl.exec_cmd("wl-clip-persist --clipboard regular")

	--# DISPLAY #--
	hl.exec_cmd("gammastep -O 5000")

	--# AUTH & SESSION #--
	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
	hl.exec_cmd("dbus-update-activation-environment --all")

	--# WALLPAPER & LOCK SCREEN #--
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("hyprsunset")
end)
