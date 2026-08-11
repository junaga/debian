local animeWallpaper = 2
local home = os.getenv("HOME")

hl.env("XCURSOR_PATH", home .. "/.local/share/icons:" .. home .. "/.icons:/usr/share/icons:/usr/share/pixmaps")
hl.env("XCURSOR_THEME", "arrow-on-text")
hl.env("XCURSOR_SIZE", "48")

hl.config({
    input = {
        -- The scrolling layout moves windows beneath a stationary pointer.
        -- Only physical pointer movement should refocus the moved content.
        mouse_refocus = false
    },
    gestures = {
        scrolling = {
            -- Gesture navigation must obey the same no-warp rule as keys.
            move_snap_cursor = false
        }
    },
    general = {
        layout           = "scrolling",
        -- Wider sides reveal the neighboring column without wasting vertical space.
        gaps_out         = { top = 27, right = 48, bottom = 27, left = 48 },
        border_size      = 0,
        gaps_in          = 8,
        resize_on_border = true
    },
    misc = {
        force_default_wallpaper = animeWallpaper
    },
    cursor = {
        enable_hyprcursor = false,
        -- Window navigation must never drag the physical pointer along with focus.
        no_warps = true
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
        dim_strength = 0.12,
        shadow = {
            color          = "#000000cc",
            color_inactive = "#00000014",
            range          = 28,
            render_power   = 3,
            offset         = { 0, 4 }
        }
    }
})

-- The Codex pet is a transparent floating surface. Do not turn its empty
-- backing surface into a visible blurred rectangle. Keep it focusable so the
-- normal window bindings, including SUPER+W, continue to target it.
hl.window_rule({
    name = "clean-codex-pet",
    match = {
        class = "^(chatgpt|codex-desktop)$",
        title = "^Codex( Pet Overlay)?$",
        float = true,
    },

    border_size = 0,
    decorate = false,
    no_anim = true,
    no_blur = true,
    no_dim = true,
    no_shadow = true,
    no_shortcuts_inhibit = true,
    rounding = 0,
})
