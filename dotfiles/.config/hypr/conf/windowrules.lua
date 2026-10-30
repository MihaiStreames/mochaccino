-- https://wiki.hypr.land/configuring/core/rules/

--# IGNORE MAXIMIZE REQUESTS #--
hl.window_rule({
	match          = { class = ".*" },
	suppress_event = "maximize",
})

--# FIX XWAYLAND DRAGGING #--
hl.window_rule({
	match = {
		class      = "^$",
		title      = "^$",
		xwayland   = true,
		float      = true,
		fullscreen = false,
		pin        = false,
	},
	no_focus = true,
})

--# NO BLUR ON CONTEXT MENUS #--
hl.window_rule({
	match   = { class = "^(.*)$", title = "^(.*)$", xwayland = true, float = true },
	no_blur = true,
})

--# FIX JETBRAINS POPUP FLICKER #--
hl.window_rule({
	match            = { class = "^(.*jetbrains.*)$", title = "^(win[0-9]+)$" },
	no_initial_focus = true,
})

--# OPACITY #--
local opacityClasses = {
	"firefox-nightly",
	"Code",
	"obsidian",
	"code-url-handler",
	"kitty",
	"thunar",
	"sublime_text",
	"nwg-look",
	"qt5ct",
	"qt6ct",
	"kvantummanager",
	"pavucontrol",
	"blueman-manager",
	"nm-applet",
	"Spotify",
	"nm-connection-editor",
	"polkit-gnome-authentication-agent-1",
	"org.freedesktop.impl.portal.desktop.gtk",
	"org.freedesktop.impl.portal.desktop.hyprland",
}
-- flip to true to re-enable (these were commented out in the old config)
local opacityEnabled = false
if opacityEnabled then
	for _, class in ipairs(opacityClasses) do
		hl.window_rule( { match = { class = "^(" .. class .. ")$" }, opacity = "0.95 0.80" } )
	end
	hl.window_rule( { match = { initial_title = "^(Spotify Free)$" }, opacity = "0.95 0.80" } )
end

--# FLOATING WINDOWS #--
local floatingClasses = {
	"kvantummanager",
	"qt5ct",
	"qt6ct",
	"nwg-look",
	"pavucontrol",
	"blueman-manager",
	"nm-applet",
	"nm-connection-editor",
	"polkit-gnome-authentication-agent-1",
}
for _, class in ipairs(floatingClasses) do
	hl.window_rule( { match = { class = "^(" .. class .. ")$" }, float = true } )
end

--# CLIPBOARD PREVIEW #--
hl.window_rule({
	match        = { class = "^(imv)$", title = "^(cliphist-preview)$" },
	float        = true,
	size         = "400 400",
	move         = "100%-420 50%-",
	pin          = true,
	animation    = "slide right",
	border_color = "rgb(f5e0dc)",
	rounding     = 10,
})

--# LAYER RULES #--
hl.layer_rule( { match = { namespace = "^(rofi)$" },  ignore_alpha = 0              } )
hl.layer_rule( { match = { namespace = "^(dunst)$" }, ignore_alpha = 0, blur = true } )
