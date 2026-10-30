-- https://wiki.hypr.land/configuring/core/binds/

--# PROGRAMS #--
local terminal     = "kitty"
local file_manager = "thunar"

-- ##; START HOSTS; DESKTOP
-- local browser = "firefox"
-- ##; END HOSTS; DESKTOP

-- ##; START HOSTS; LAPTOP
local browser = "firefox-nightly"
-- ##; END HOSTS; LAPTOP

local color_picker = "hyprpicker"
local pass_manager = "keepassxc"

local mainMod = "SUPER"
local rofi    = "~/.config/rofi/scripts/"

--# WINDOW MANAGEMENT #--
hl.bind( "CTRL + Q",        hl.dsp.window.close()                      )
hl.bind( mainMod .. " + M", hl.dsp.exit()                              )
hl.bind( mainMod .. " + W", hl.dsp.window.float({ action = "toggle" }) )
hl.bind( mainMod .. " + P", hl.dsp.window.pseudo()                     )
hl.bind( mainMod .. " + J", hl.dsp.layout("togglesplit")               )

--# APPS #--
hl.bind( "CTRL + ALT + T",          hl.dsp.exec_cmd(terminal)                       )
hl.bind( mainMod .. " + E",         hl.dsp.exec_cmd(file_manager)                   )
hl.bind( mainMod .. " + K",         hl.dsp.exec_cmd(pass_manager)                   )
hl.bind( mainMod .. " + B",         hl.dsp.exec_cmd(browser)                        )
hl.bind( mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(browser .. " --private-window") )

--# SCREENSHOTS #--
hl.bind( mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region -m active --clipboard-only --silent --freeze") )

--# LOCK SCREEN #--
hl.bind( mainMod .. " + L", hl.dsp.exec_cmd("hyprlock") )

--# COLOR PICKER #--
hl.bind( mainMod .. " + P", hl.dsp.exec_cmd(color_picker .. " | wl-copy") )

--# LOGOUT MENU #--
hl.bind( mainMod .. " + ESCAPE", hl.dsp.exec_cmd("wlogout") )

--# MOVE FOCUS #--
hl.bind( mainMod .. " + left",  hl.dsp.focus({ direction = "left" })  )
hl.bind( mainMod .. " + right", hl.dsp.focus({ direction = "right" }) )
hl.bind( mainMod .. " + up",    hl.dsp.focus({ direction = "up" })    )
hl.bind( mainMod .. " + down",  hl.dsp.focus({ direction = "down" })  )

--# CYCLE WINDOWS #--
hl.bind( "ALT + Tab", hl.dsp.window.cycle_next() )

--# ROFI LAUNCHERS #--
hl.bind( mainMod .. " + SUPER_L",   hl.dsp.exec_cmd(rofi .. "launchpad.sh"),  { release = true } )
hl.bind( mainMod .. " + SPACE",     hl.dsp.exec_cmd(rofi .. "launcher.sh")                       )
hl.bind( mainMod .. " + R",         hl.dsp.exec_cmd(rofi .. "run.sh")                            )
hl.bind( mainMod .. " + Z",         hl.dsp.exec_cmd(rofi .. "filebrowser.sh")                    )
hl.bind( mainMod .. " + SHIFT + V", hl.dsp.exec_cmd(rofi .. "clipboard.sh")                      )
hl.bind( "CTRL + ALT + W",          hl.dsp.exec_cmd(rofi .. "wallpaper.sh")                      )
hl.bind( mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(rofi .. "theme.sh")                          )

--# WORKSPACES (0 IS 10) #--
for i = 1, 10 do
	local key = i % 10 -- workspace 10 is on key 0
	hl.bind( mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i })       )
	hl.bind( mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }) )
end

--# MOVE/RESIZE WITH MOUSE #--
hl.bind( mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true } )
hl.bind( mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true } )

--# RESIZE WITH KEYBOARD #--
hl.bind( mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 10, y = 0, relative = true })  )
hl.bind( mainMod .. " + SHIFT + left",  hl.dsp.window.resize({ x = -10, y = 0, relative = true }) )
hl.bind( mainMod .. " + SHIFT + up",    hl.dsp.window.resize({ x = 0, y = -10, relative = true }) )
hl.bind( mainMod .. " + SHIFT + down",  hl.dsp.window.resize({ x = 0, y = 10, relative = true })  )

-- ##; START HOSTS; LAPTOP
--# MULTIMEDIA KEYS #--
local mediaOpts = { locked = true, repeating = true }
hl.bind( "XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), mediaOpts )
hl.bind( "XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      mediaOpts )
hl.bind( "XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     mediaOpts )
hl.bind( "XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   mediaOpts )

hl.bind( "XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), mediaOpts )
hl.bind( "XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), mediaOpts )

--# BLUETOOTH & WIFI #--
hl.bind( "XF86Bluetooth", hl.dsp.exec_cmd("rfkill toggle bluetooth") )
hl.bind( "XF86WLAN",      hl.dsp.exec_cmd("rfkill toggle wlan")      )
-- ##; END HOSTS; LAPTOP
