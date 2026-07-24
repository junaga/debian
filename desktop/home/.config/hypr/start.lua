start = "hyprland-run"

-- Open Start when the left Super key is pressed and released by itself.
hl.bind("SUPER + SUPER_L", hl.dsp.exec_cmd(start), { release = true })

hl.window_rule({
    name  = "start",
    match = { class = start },

    -- Coordinates start at the top-left, so subtracting 120 from the monitor
    -- height places Start near the bottom instead of below the screen.
    move  = { 20, "monitor_h-120" },
    float = true
})
