-- https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
	general = {
		gaps_in    = 5,
		gaps_out   = 5,

		border_size = 2,

		resize_on_border   = true,
		allow_tearing      = false,

		layout = "dwindle",
	},

	decoration = {
		rounding = 10,

		active_opacity     = 1.0,
		inactive_opacity   = 1.0,

		blur = {
			enabled             = false,
			size                = 3,
			passes              = 2,
			new_optimizations   = true,
			vibrancy            = 0.1696,
			ignore_opacity      = true,
		},
	},

	animations = {
		enabled = true,
	},

	dwindle = {
		preserve_split = true,
	},

	master = {
		new_status = "master",
		new_on_top = true,
	},

	misc = {
		force_default_wallpaper    = 0,
		disable_hyprland_logo      = true,
		disable_splash_rendering   = true,
	},
})

-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/#curves

hl.curve("easeOutQuint",     { type = "bezier",   points = { { 0.23, 1    },   { 0.32, 1 } } } )
hl.curve("easeInOutCubic",   { type = "bezier",   points = { { 0.65, 0.05 },   { 0.36, 1 } } } )
hl.curve("easeOutQuint",     { type = "bezier",   points = { { 0,    0    },   { 1,    1 } } } )
hl.curve("easeOutQuint",     { type = "bezier",   points = { { 0.5,  0.5  },   { 0.75, 1 } } } )
hl.curve("easeOutQuint",     { type = "bezier",   points = { { 0.15, 0    },   { 0.1,  1 } } } )

-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/

hl.animation( { leaf = "global",          enabled = true,   speed = 10,     bezier = "default"                           } )
hl.animation( { leaf = "border",          enabled = true,   speed = 1,      bezier = "linear"                            } )
hl.animation( { leaf = "windows",         enabled = true,   speed = 4.79,   bezier = "easeOutQuint"                      } )
hl.animation( { leaf = "windowsIn",       enabled = true,   speed = 4.1,    bezier = "easeOutQuint", style = "popin 87%" } )
hl.animation( { leaf = "windowsOut",      enabled = true,   speed = 1.49,   bezier = "linear",       style = "popin 87%" } )
hl.animation( { leaf = "fadeIn",          enabled = true,   speed = 1.73,   bezier = "almostLinear"                      } )
hl.animation( { leaf = "fadeOut",         enabled = true,   speed = 1.46,   bezier = "almostLinear"                      } )
hl.animation( { leaf = "fade",            enabled = true,   speed = 3.03,   bezier = "quick"                             } )
hl.animation( { leaf = "layers",          enabled = true,   speed = 3.81,   bezier = "easeOutQuint"                      } )
hl.animation( { leaf = "layersIn",        enabled = true,   speed = 4,      bezier = "easeOutQuint", style = "fade"      } )
hl.animation( { leaf = "layersOut",       enabled = true,   speed = 1.5,    bezier = "linear",       style = "fade"      } )
hl.animation( { leaf = "fadeLayersIn",    enabled = true,   speed = 1.79,   bezier = "almostLinear"                      } )
hl.animation( { leaf = "fadeLayersOut",   enabled = true,   speed = 1.39,   bezier = "almostLinear"                      } )
hl.animation( { leaf = "workspaces",      enabled = true,   speed = 1.94,   bezier = "almostLinear", style = "fade"      } )
hl.animation( { leaf = "workspacesIn",    enabled = true,   speed = 1.21,   bezier = "almostLinear", style = "fade"      } )
hl.animation( { leaf = "workspacesOut",   enabled = true,   speed = 1.94,   bezier = "almostLinear", style = "fade"      } )
