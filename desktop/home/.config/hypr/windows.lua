-------------
-- Display --
-------------

-- enable VSync
hl.config({ general = { allow_tearing = false } })


-------------
-- Desktop --
-------------

-- Windows form one-third-width columns on a horizontal tape.
--   one:  [      A      ]
--   many: [ A ][ B ][ C ] -> [ D ] ...
hl.config({
    general = { layout = "scrolling" },
    scrolling = {
        column_width = 1 / 3,
        fullscreen_on_one_column = false
    }
})

local animeWallpaper = 2
hl.config({ misc = { force_default_wallpaper = animeWallpaper } })

require("motion")

-- Create desktop surfaces.
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })

-- Manage workspace transitions, layer surfaces, and cursor zoom.
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "layers",     enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7,    bezier = "quick" })

-- Destroy desktop surfaces.
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })


-------------
-- Windows --
-------------

theme = require("theme")

hl.config({
    general = {
        gaps_out    = 27,
        border_size = 0,
        gaps_in     = 8
    },
    decoration = {
        blur = { size = theme.blur },
        rounding     = theme.rounding,

        -- The focused window stays bright and elevated while inactive windows recede.
        dim_inactive = true,
        dim_strength = 0.20,
        shadow = {
            color          = "#000000cc",
            color_inactive = "#00000033",
            range          = 64,
            render_power   = 2,
            offset         = { 0, 2 }
        }
    }
})

-- Create a window.
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "fadeIn",    enabled = true, speed = 1.73, bezier = "almostLinear" })

-- Manage window movement and persistent effects.
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "fade",   enabled = true, speed = 3.03, bezier = "quick" })

-- Destroy a window.
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeOut",    enabled = true, speed = 1.46, bezier = "almostLinear" })

-- Prevent anonymous XWayland drag surfaces from stealing focus.
hl.window_rule({
    name = "fix-xwayland-drags",
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
