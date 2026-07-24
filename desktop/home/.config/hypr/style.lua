hl.config({
    general = {
        gaps_out    = 27,
        border_size = 0,
        gaps_in     = 8
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
