local animeWallpaper = 2
local home = os.getenv("HOME")

hl.env("XCURSOR_PATH", home .. "/.local/share/icons:" .. home .. "/.icons:/usr/share/icons:/usr/share/pixmaps")
hl.env("XCURSOR_THEME", "arrow-on-text")
hl.env("XCURSOR_SIZE", "48")

hl.config({
    general = {
        layout           = "scrolling",
        gaps_out         = 27,
        border_size      = 1,
        gaps_in          = 8,
        resize_on_border = true,
        col = {
            -- A quiet slate gradient marks focus; inactive windows keep a clean edge.
            active_border = {
                colors = { "rgba(475569b3)", "rgba(64748bb3)", "rgba(6b617db3)" },
                angle = 45
            },
            inactive_border = "rgba(00000000)"
        }
    },
    misc = {
        force_default_wallpaper = animeWallpaper
    },
    cursor = {
        enable_hyprcursor = false
    },
    scrolling = {
        -- Mobile (~500 px), mainframe/terminal (~720 px), desktop (~1024 px),
        -- web (~1280 px), and full width.
        column_width             = 0.553,
        explicit_column_widths   = "0.272, 0.391, 0.553, 0.690, 1.0",
        fullscreen_on_one_column = false,
        wrap_focus               = false,
        wrap_swapcol             = false
    },
    decoration = {
    		-- motion_blur = true,
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
