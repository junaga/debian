--------------
-- Keyboard --
--------------

local columns = require("core.columns")
local start = require("core.start")

function open(keys, command)
    hl.bind(keys, hl.dsp.exec_cmd(command))
end

-- Desktop.
hl.bind("SUPER + R",         hl.dsp.exec_cmd(start))
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("hyprshutdown"))
hl.bind("SUPER + W",         hl.dsp.window.close())

-- Navigation.
hl.bind("SUPER + left",        hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + SHIFT + tab", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right",       hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + tab",         hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + home",        columns.focusFirst)
hl.bind("SUPER + end",         columns.focusLast)

-- Switch workspaces, or move the active window with Shift.
for i = 1, 10 do
    local key = i % 10
    hl.bind(("SUPER + %d"):format(key),         hl.dsp.focus({ workspace = i }))
    hl.bind(("SUPER + SHIFT + %d"):format(key), hl.dsp.window.move({ workspace = i }))
end

-- Sizing.
hl.bind("SUPER + up",     hl.dsp.layout("colresize +conf"))
hl.bind("SUPER + down",   hl.dsp.layout("colresize -conf"))
hl.bind("SUPER + insert", columns.saveWidth)

---------------------------------------
-- Mouse; Macintosh (1984) onward. --
---------------------------------------

-- Scroll through columns on the active workspace.
hl.bind("SUPER + mouse_down", hl.dsp.layout("focus r"))
hl.bind("SUPER + mouse_up",   hl.dsp.layout("focus l"))

-- Move and resize windows with Super + left/right mouse drag.
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })


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
