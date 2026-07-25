--------------
-- Keyboard --
--------------

hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("hyprshutdown"))
hl.bind("SUPER + W", hl.dsp.window.close())
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + P", hl.dsp.exec_cmd(screenshot))

hl.bind("SUPER + T", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + E", hl.dsp.exec_cmd(explorer))
hl.bind("SUPER + B", hl.dsp.exec_cmd(browser))


---------------------------------------
-- Mouse; Macintosh (1984) onward. --
---------------------------------------

hl.env("XCURSOR_SIZE", "48")

hl.config({
    input = {
        scroll_factor = 1.0
    }
})

if hl.plugin.windows_pointer_linux then
    hl.config({
        plugin = {
            windows_pointer_linux = {
                pointer_speed = "10/20",
                enhance_pointer_precision = true
            }
        }
    })
end

------------------------------------
-- Media; iBook (1999) onward. --
------------------------------------

-- Volume controls.
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"), { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"), { locked = true })

-- Playback controls (requires playerctl).
hl.bind("XF86AudioPlay",    hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause",   hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",    hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",    hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("XF86AudioForward", hl.dsp.exec_cmd("playerctl position 0.1+"), { locked = true, repeating = true })
hl.bind("XF86AudioRewind",  hl.dsp.exec_cmd("playerctl position 0.1-"), { locked = true, repeating = true })


----------
-- TODO --
----------

-- Move focus with Super + arrow keys.
hl.bind("SUPER + left",  hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up",    hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces, or move the active window with Shift.
for i = 1, 10 do
    local key = i % 10
    hl.bind(("SUPER + %d"):format(key),         hl.dsp.focus({ workspace = i }))
    hl.bind(("SUPER + SHIFT + %d"):format(key), hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces.
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move and resize windows with Super + left/right mouse drag.
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
