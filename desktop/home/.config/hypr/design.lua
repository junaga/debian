-- Hyprland's visual configuration.
--
-- Portable visual preferences live in theme.lua. Everything below
-- is specific to how Hyprland presents windows and the desktop.

theme = require("theme")
colors = theme.colors

hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "48")

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 20,
        border_size = 2,
        col = {
            active_border = colors.primary,
            inactive_border = colors.muted
        },
        resize_on_border = true
    },
    decoration = {
        rounding = 10,
        shadow = { enabled = false },
        blur = {
            enabled = true,
            size = theme.background.blur
        }
    }
})
