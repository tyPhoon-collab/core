local wezterm = require("wezterm")
local act = wezterm.action

return {
	automatically_reload_config = true,
	use_ime = true,
	window_close_confirmation = "NeverPrompt",
	color_scheme = "Tokyo Night Storm",
	font = wezterm.font_with_fallback({
		"Hack Nerd Font Mono",
		"Hiragino Sans",
	}),
	keys = {
		{ key = "w", mods = "SUPER", action = act.CloseCurrentTab({ confirm = false }) },
	},
}