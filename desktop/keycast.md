# Keycast

A small always-visible overlay showing recent keys without stealing focus,
pointer events, or shortcuts from the window underneath.

- Show typed text briefly; reset a word after about 1.8 seconds idle.
- Show modifier chords compactly, then clear them quickly.
- Become interactive only while both hovered and `Super` is held.
- While interactive, allow dragging, show a simple desktop grid, snap to a
  grid position on release, and remember the monitor and position.
- Open with `Super+K` and close through the normal window shortcut.
- Use one real surface and native Wayland/Hyprland facilities. Do not grab or
  synthesize input, redirect clicks, or stack a hidden control window.
- Never log or persist captured keys; persist only placement.

## Visuals

- A decorationless `760 × 96` panel with `24 px` horizontal and `16 px`
  vertical padding; never show it in the taskbar or workspace switcher.
- Near-black warm background (`rgba(5, 3, 0, 0.88)`) and a `2 px` dark-amber
  border; brighten the border and background only while interactive.
- Bold `36 px` monospace text in amber (`#ffb84d`) with a restrained glow;
  brighten it to `#ffd08a` while interactive without shifting the layout.
- During dragging, draw a transparent `3 × 5` desktop grid using thin,
  low-opacity amber lines. Tint the selected cell and outline the exact snapped
  panel position with a stronger `3 px` stroke.
