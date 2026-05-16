-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

--# 1. IGNORE MAXIMIZE REQS FROM APPS #--
--# 2. FIX DRAGGING ISSUES WITH XWAYLAND #--
--# 3. FIX JETBRAINS IDES DROPDOWNS FLICKERING #--

hl.window_rule({
	name  = "suppress-maximize",
	match = {
		class = ".*",
	},
	suppress_event = "maximize",
})

hl.window_rule({
	name  = "fix-xwayland-drags",
	match = {
		class        = "^$",
		title        = "^$",
		xwayland     = true,
		float        = true,
		fullscreen   = false,
		pin          = false,
	},
	no_focus = true,
})

hl.window_rule({
	name  = "jetbrains-no-initial-focus",
	match = {
		class = "^(.*jetbrains.*)$",
		title = "^(win[0-9]+)$"
	},
	no_initial_focus = true,
})

-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/#layer-rules
