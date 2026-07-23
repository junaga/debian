-- Portable desktop theme: plain sRGB colors and shared visual proportions.

return {
    colors = {
        background = "#050300",
        accent     = "#ffb84d",
        highlight  = "#ffd28a",
        muted      = "#d8912f",
        inverse    = "#120800",
        shadow     = "#000000"
    },

    font = "Fira Code",

    opacity = 0.88,

    gaps = {
        inner = 5,
        outer = 20
    },

    border = 0,

    corners = {
        radius = 10,
        power  = 2
    },

    shadow = {
        range = 64,
        power = 2
    },

    blur = {
        size     = 3,
        passes   = 1,
        vibrancy = 0.1696
    }
}
