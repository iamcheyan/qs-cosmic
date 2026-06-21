hl.monitor({
	output = "eDP-1",
	mode = "3024x1890@120",
	position = "8132x1080",
	scale = 2,
})

hl.monitor({
	output = "HDMI-A-1",
	mode = "3840x2160@60",
	position = "9644x0",
	scale = 2,
})

hl.config({
	input = {
		kb_layout = "jp",
		kb_model = "jp106",
	}
})

hl.config({
	decoration = {
		rounding = 0,
		rounding_power = 2,
		blur = {
			enabled = false,
		},
		shadow = {
			enabled = false,
		},
		dim_inactive = false,
	}
})

hl.config({
	general = {
		gaps_in = 0,
		gaps_out = 0,
		border_size = 2,
		col = {
			active_border = "rgba(66ccffff)",
			inactive_border = "rgba(333333ff)",
		},
	},
	animations = {
		enabled = false,
	}
})
