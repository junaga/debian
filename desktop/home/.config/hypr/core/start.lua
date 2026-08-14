-- TODO: Delete this comment after Debian ships a Hyprtoolkit release that
-- includes https://github.com/hyprwm/hyprtoolkit/commit/bf9219cc53548c119e61d74b210076ceeded1f65
--
-- Debian's current Hyprtoolkit package ships 0.5.4. That version routes
-- keyboard events to Hyprtoolkit's `m_currentWindow`, but it sets and clears
-- that variable from `wl_pointer.enter` and `wl_pointer.leave`. It does not
-- track `wl_keyboard.enter` or `wl_keyboard.leave`. As a result,
-- hyprland-run receives text and Escape only while the mouse pointer is
-- physically inside its surface, even when Hyprland correctly reports the
-- launcher as the active, keyboard-focused window.
--
-- Upstream fixed the bug by tracking a separate `m_keyboardWindow` from the
-- Wayland keyboard enter/leave events and routing key and repeat events to
-- it. The fix was committed after the 0.5.4 release and has not yet appeared
-- in a tagged Hyprtoolkit release or Debian package. There is intentionally
-- no compositor workaround here: this rule describes where Start belongs,
-- and hyprland-run should obey normal Wayland keyboard focus once Debian
-- packages the upstream fix.

local start = "hyprland-run"

hl.window_rule({
    match = { class = start },

    -- Coordinates start at the top-left, so subtracting 120 from the monitor
    -- height places Start near the bottom instead of below the screen.
    move  = { 20, "monitor_h-120" },
    float = true
})

return "pkill -fx " .. start .. " || " .. start
