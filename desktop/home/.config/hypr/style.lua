-----------
-- Style --
-----------

local theme = {
    font = "Fira Code",

    colors = {
        background = "#050300",
        accent     = "#ffb84d",
        highlight  = "#ffd28a",
        muted      = "#d8912f",
        inverse    = "#120800"
    },

    opacity = 0.88,
    rounding = 10,
    blur = 3
}

hl.config({
    general = {
        gaps_out    = 27,
        border_size = 0,
        gaps_in     = 8
    },
    decoration = {
        blur = { size = theme.blur },
        rounding = theme.rounding,

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
