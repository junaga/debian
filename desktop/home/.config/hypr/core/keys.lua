--------------
-- Keyboard --
--------------

function open(keys, command, rules)
    if rules then
        command = "exec " .. command
    end

    hl.bind(keys, hl.dsp.exec_cmd(command, rules))
end

function close(keys)
    hl.bind(keys, hl.dsp.window.close())
end

function exit(keys)
    hl.bind(keys, hl.dsp.exec_cmd("hyprshutdown"))
end

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


----------------
-- Navigation --
----------------

-- Navigate columns by their physical order.
local previousColumn = hl.dsp.layout("focus l")
local nextColumn = hl.dsp.layout("focus r")

hl.bind("SUPER + left",        previousColumn)
hl.bind("SUPER + SHIFT + tab", previousColumn)
hl.bind("SUPER + right",       nextColumn)
hl.bind("SUPER + tab",         nextColumn)

-- Restore the focused column to the configured default width.
hl.bind("SUPER + backspace", hl.dsp.layout("colresize 0.667"))

-- Move and resize windows with Super + left/right mouse drag.
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
