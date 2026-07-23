-- Hyprland's visual configuration.
--
-- Portable visual preferences live in theme.lua. Everything below
-- is specific to how Hyprland presents windows and the desktop.

theme = require("theme")

hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 20,
        border_size = 2,
        col = {
            active_border = {
                colors = {"rgba(33ccffee)", "rgba(00ff99ee)"},
                angle = 45
            },
            inactive_border = "rgba(595959aa)"
        },
        resize_on_border = true
    },
    decoration = {
        rounding = 10,
        rounding_power = 2,
        active_opacity = 1,
        inactive_opacity = 1,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a
        },
        blur = {
            enabled = true,
            size = theme.background.blur,
            passes = 1,
            vibrancy = 0.1696
        }
    }
})
