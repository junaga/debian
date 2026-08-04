--------------
-- Keyboard --
--------------

local columns = require("core.columns")
local start = require("core.start")
local tape = require("core.tape")

local function open(keys, command)
    hl.bind(keys, hl.dsp.exec_cmd(command))
end

local function zoom(amount)
    local current = hl.get_config("cursor:zoom_factor")
    local factor = math.max(1.0, math.min(20.0, current + amount))

    hl.config({ cursor = { zoom_factor = factor } })
end

-- Desktop.
hl.bind("SUPER + R",         hl.dsp.exec_cmd(start))
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("hyprshutdown"))
hl.bind("SUPER + W",         hl.dsp.window.close())
-- hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("hyprshutdown --vt --post-cmd 'systemctl poweroff'"))

-- Navigation.
hl.bind("SUPER + up",          tape.previous)
hl.bind("SUPER + SHIFT + tab", tape.previous)
hl.bind("SUPER + down",        tape.next)
hl.bind("SUPER + tab",         tape.next)
hl.bind("SUPER + home",        tape.first)
hl.bind("SUPER + end",         tape.last)
hl.bind("SUPER + page_up",     hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + page_down",   hl.dsp.focus({ workspace = "e+1" }))

-- Movement.
hl.bind("SUPER + SHIFT + up",        tape.movePrevious)
hl.bind("SUPER + SHIFT + down",      tape.moveNext)
hl.bind("SUPER + SHIFT + home",      tape.sendFirst)
hl.bind("SUPER + SHIFT + end",       tape.sendLast)
hl.bind("SUPER + SHIFT + page_up",   tape.sendPreviousWorkspace)
hl.bind("SUPER + SHIFT + page_down", tape.sendNextWorkspace)

-- Switch workspaces, or move the active window with Shift.
for i = 1, 10 do
    local key = i % 10
    hl.bind(("SUPER + %d"):format(key),         hl.dsp.focus({ workspace = i }))
    hl.bind(("SUPER + SHIFT + %d"):format(key), hl.dsp.window.move({ workspace = i }))
end

-- Sizing.
hl.bind("SUPER + left",  columns.narrow)
hl.bind("SUPER + right", columns.widen)
hl.bind("SUPER + KP_Subtract", function() zoom(-0.3) end, { repeating = true, description = "Screen: Zoom out" })
hl.bind("SUPER + KP_Add",      function() zoom(0.3) end,  { repeating = true, description = "Screen: Zoom in" })

---------------------------------------
-- Mouse; Macintosh (1984) onward. --
---------------------------------------

-- Remember columns changed by mouse or border resizing.
for _, button in ipairs({ 272, 273 }) do
    local key = ("mouse:%d"):format(button)
    hl.bind(key, columns.beginResize, { ignore_mods = true, non_consuming = true })
    hl.bind(key, columns.endResize,   { ignore_mods = true, non_consuming = true, release = true })
end

-- Scroll through the same global tape as the keyboard.
hl.bind("SUPER + mouse_down", tape.next)
hl.bind("SUPER + mouse_up",   tape.previous)

-- Move and resize windows with Super + left/right mouse drag.
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:272", columns.beginDrag,      { non_consuming = true })
hl.bind("SUPER + mouse:272", columns.endDrag,        { drag = true, non_consuming = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

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

return open
