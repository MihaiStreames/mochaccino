-- https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
	input = {
		kb_layout      = "us",
		follow_mouse   = 1,
		sensitivity    = 0,

-- ##; START HOSTS; LAPTOP
		touchpad = {
			natural_scroll         = false,
			disable_while_typing   = false,
		},
-- ##; END HOSTS; LAPTOP

	},
})

-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/

-- ##; START HOSTS; LAPTOP
hl.gesture( { fingers = 3,   direction = "horizontal",   action =  "workspace" })
-- ##; END HOSTS; LAPTOP
