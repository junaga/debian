-------------
-- Desktop --
-------------

hl.config({
    general = { layout = "scrolling" },
    scrolling = { column_width = 0.667 }
})

local animeWallpaper = 2
hl.config({ misc = { force_default_wallpaper = animeWallpaper } })

-- Keep application-owned dialogs out of the tiled column layout.
hl.window_rule({
    match = { modal = true },
    float = true
})


-----------
-- Style --
-----------

hl.config({
    general = {
        gaps_out    = 27,
        border_size = 0,
        gaps_in     = 8,
        resize_on_border = true
    },
    decoration = {
        blur = { size = 3 },
        rounding = 10,

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
