-- https://wiki.hypr.land/configuring/core/config-options/

hl.config({
	input = {
		kb_layout    = "us",
		follow_mouse = 1,
		sensitivity  = 0,

		-- ##; START HOSTS; LAPTOP
		touchpad = {
			natural_scroll       = false,
			disable_while_typing = false,
		},
		-- ##; END HOSTS; LAPTOP
	},
})

-- ##; START HOSTS; LAPTOP
hl.gesture({
	fingers   = 3,
	direction = "horizontal",
	action    = "workspace",
})
-- ##; END HOSTS; LAPTOP
