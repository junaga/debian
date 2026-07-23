-- Previous custom design, retained while rebuilding from the default.

theme = require("theme")

hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "48")

hl.config({
    general = {
        layout = "scrolling",
        gaps_in = 5,
        gaps_out = 20,
        border_size = 2,
        col = {
            active_border = theme.colors.primary,
            inactive_border = theme.colors.muted .. "66"
        },
        resize_on_border = true
    },
    scrolling = {
        column_width = 1 / 3
    },
    decoration = {
        rounding = 10,
        blur = {
            enabled = true,
            size = theme.background.blur
        }
    }
})
