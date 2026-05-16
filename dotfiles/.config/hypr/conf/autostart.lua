-- https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
	--# 1. STATUS BAR & NOTIFICATIONS #--
	--# 2. SYS TRAY APPLETS #--
	--# 3. CLIPBOARD #--
	--# 4. AUTH & SESSION #--
	--# 5. WP, LOCK SCREEN, FILTER #--

	hl.exec_cmd("waybar")
	hl.exec_cmd("dunst")

	hl.exec_cmd("nm-applet --indicator")
	hl.exec_cmd("blueman-applet")

	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
	hl.exec_cmd("wl-clip-persist --clipboard regular")

	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
	hl.exec_cmd("dbus-update-activation-environment --all")

	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("hyprsunset")
end)
