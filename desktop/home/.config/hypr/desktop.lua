local animeWallpaper = 2

hl.env("XCURSOR_THEME", "arrow-on-text")
hl.env("XCURSOR_SIZE", "48")

hl.config({
    general = {
        layout           = "scrolling",
        gaps_out         = 27,
        border_size      = 0,
        gaps_in          = 8,
        resize_on_border = true
    },
    misc = {
        force_default_wallpaper = animeWallpaper
    },
    cursor = {
        enable_hyprcursor = false
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
