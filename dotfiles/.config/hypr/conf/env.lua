-- https://wiki.hypr.land/configuring/core/environment-variables/

--# CURSOR #--
hl.env( "XCURSOR_SIZE",     "24"                )
hl.env( "HYPRCURSOR_THEME", "Bibata-Modern-Ice" )
hl.env( "HYPRCURSOR_SIZE",  "24"                )

-- ##; START HOSTS; DESKTOP
--# NVIDIA #--
-- hl.env( "LIBVA_DRIVER_NAME",         "nvidia"     )
-- hl.env( "__GLX_VENDOR_LIBRARY_NAME", "nvidia"     )
-- hl.env( "GBM_BACKEND",               "nvidia-drm" )
-- hl.env( "__GL_GSYNC_ALLOWED",        "1"          )
-- hl.env( "__GL_VRR_ALLOWED",          "0"          )
-- hl.env( "WLR_NO_HARDWARE_CURSORS",   "1"          )
-- hl.env( "NVD_BACKEND",               "direct"     )
-- ##; END HOSTS; DESKTOP

--# ELECTRON #--
hl.env( "ELECTRON_OZONE_PLATFORM_HINT", "auto" )

--# D-BUS SESSION ADDR #--
-- hl.env doesn't expand $VARS like hyprlang did, so read it from the environment
hl.env( "DBUS_SESSION_BUS_ADDRESS", "unix:path=" .. (os.getenv("XDG_RUNTIME_DIR") or "/run/user/1000") .. "/bus" )

--# FIREFOX #--
hl.env( "MOZ_ENABLE_WAYLAND", "1" )

--# QT #--
hl.env( "QT_QPA_PLATFORM",                     "wayland" )
hl.env( "QT_QPA_PLATFORMTHEME",                "qt5ct"   )
hl.env( "QT_WAYLAND_DISABLE_WINDOWDECORATION", "1"       )
hl.env( "QT_AUTO_SCREEN_SCALE_FACTOR",         "1"       )
hl.env( "QT_STYLE_OVERRIDE",                   "kvantum" )

--# TOOLKIT BACKEND VARS #--
hl.env( "GDK_BACKEND",     "wayland,x11,*" )
hl.env( "SDL_VIDEODRIVER", "wayland"       )
hl.env( "CLUTTER_BACKEND", "wayland"       )

--# XDG SPECS #--
hl.env( "XDG_CURRENT_DESKTOP", "Hyprland" )
hl.env( "XDG_SESSION_TYPE",    "wayland"  )
hl.env( "XDG_SESSION_DESKTOP", "Hyprland" )

--# KEYRING #--
hl.env( "GNOME_KEYRING_CONTROL", "/run/user/1000/keyring/control" )
hl.env( "SSH_AUTH_SOCK",         "/run/user/1000/keyring/ssh"     )
