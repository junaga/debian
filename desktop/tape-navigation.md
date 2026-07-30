# Tape edge navigation

Status: design only; currently not implemented.

## Goal

Hyprland's scrolling layout leaves fragments of neighboring windows visible at
the monitor edges. Hovering one should reveal a small arrow. Clicking anywhere
in that fragment should focus that exact window and bring it into view.

This adds direct mouse navigation to the existing keyboard-controlled tape
without permanent buttons or pointer movement.

## Behavior

- Resolve targets independently for each monitor's active workspace.
- A target is a mapped, visible, inactive, tiled window crossing the left or
  right monitor boundary.
- Exclude floating, hidden, fully visible, fully hidden, and fullscreen windows.
- Expose at most one target per side: the clipped window nearest that boundary.
- Use the complete visible fragment as both hover and click area.
- Hovering shows the cue but does not focus or move anything.
- Primary click focuses the exact represented window and consumes the click.
- Never warp, snap, or confine the physical pointer.
- Once the tape settles, show the cue for a new fragment beneath the pointer or
  hide it if none exists.
- Keyboard navigation remains independent.

## Appearance

Nothing is visible at rest. Hover adds:

- a centered left or right chevron, approximately 9 × 18 px;
- a 2.6 px rounded stroke in `rgba(245, 248, 255, 0.92)`;
- a charcoal wash (`rgb(7, 10, 16)`) fading from the monitor edge into the
  window, with approximate opacities `0.34`, `0.08`, and `0.02`;
- an 80 ms ease-out opacity transition.

Pressing may strengthen the wash by about 15%.

Do not add shadows, glows, pills, panels, borders, tooltips, labels, permanent
arrows, bounce, scaling, or positional animation.

## Implementation requirements

- Track targets by stable Hyprland window identity, not only geometry.
- Update the model, drawing, and input regions atomically.
- Intercept input only inside visible target fragments; everything else must be
  click-through.
- Do not create, destroy, or resize surfaces during ordinary pointer movement.
- Use event-driven updates; do not spawn subprocesses at frame rate.
- During activation, retain the selected identity until layout animation
  settles. Do not react to transient geometry as if it were a new user action.
- Fail closed when IPC is unavailable: draw nothing and intercept nothing.
- Handle multiple monitors, logical coordinates, scale, workspace changes,
  fullscreen changes, and both Wayland and XWayland windows.

## Hyprland and Wayland hazards

- Changing a Wayland input region can emit pointer enter/leave events without
  physical pointer movement. Those events cannot be the sole hover authority.
- Scrolling animation produces several transitional geometry and focus events
  for one action.
- `follow_mouse = 1` can undo navigation when windows move under a stationary
  pointer. The desktop keeps `input.mouse_refocus = false`.
- Gesture cursor snapping is separate from `cursor.no_warps`. The desktop keeps
  `gestures.scrolling.move_snap_cursor = false`.
- Hyprland Lua can inspect and dispatch compositor state but currently provides
  no first-class interactive drawing surface. Use a plugin or a carefully
  designed layer-shell client.

## Acceptance checks

1. Hovering either edge always reveals immediately and leaving always hides.
2. Ten consecutive clicks in either direction produce exactly ten focus moves.
3. The arrow never flickers, duplicates, sticks, or disappears from a valid
   stationary target during tape motion.
4. Focus never bounces back to a window moved beneath the pointer.
5. The physical pointer coordinates never change.
6. Clicks outside fragments always reach the underlying application; activation
   clicks never do.
7. Resizing, opening, closing, fullscreening, switching workspaces, reloading
   Hyprland, and reconnecting monitors leave no stale targets.
8. Killing the implementation immediately restores a fully interactive desktop
   with no stale surfaces.
