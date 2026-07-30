# Tape edge navigation

## Status

This document is a product and interaction specification for a future feature.
The feature is intentionally **not implemented** in the current desktop.

The specification preserves the interaction that felt good while separating it
from the failed prototypes. It does not prescribe Python, Lua, GTK, a Hyprland
plugin, or any other implementation.

## Product intent

Hyprland's scrolling layout presents the workspace as a horizontal tape of
window columns. The monitor is a viewport into that tape. A neighboring window
may be partly visible at the left or right edge, naturally communicating that
more content exists outside the viewport.

Tape edge navigation turns that already-visible fragment into a direct mouse
target:

1. Point at the visible part of a clipped neighboring window.
2. Receive a small, immediate directional cue.
3. Click anywhere in that fragment.
4. Bring that exact window fully into view and focus it.

The result complements the existing keyboard navigation. It must feel like
directly choosing a physical object, not operating a scrollbar or clicking a
permanent desktop control.

## Design principles

- Use the window fragment that is already visible; add no permanent chrome.
- Preserve spatial continuity. The selected window, not merely a direction, is
  the navigation target.
- Never move the physical pointer.
- Make the full visible fragment clickable rather than demanding precision on a
  small icon.
- Keep the visual cue quiet enough that the window remains the object.
- Treat every focus-and-scroll operation as one atomic interaction.
- Prefer no feature over a feature that flickers, steals clicks, changes focus
  twice, or occasionally fails to appear.

## Terminology

- **Tape:** the ordered horizontal set of tiled scrolling-layout columns.
- **Viewport:** one monitor's visible workspace area.
- **Clipped window:** a tiled window crossing the viewport's left or right
  boundary.
- **Fragment:** the portion of a clipped window visible inside the viewport.
- **Target:** the one fragment selected for interaction on a given side.
- **Selected window:** the exact Hyprland window represented by the target.
- **Settle:** the point at which focus, scrolling-layout geometry, animation,
  input routing, and pointer hit testing agree after activation.

## Eligibility

A window is eligible only when all of the following are true:

- It is mapped and visible.
- It is tiled in the scrolling layout.
- It belongs to the active workspace of the relevant monitor.
- It is not the selected/focused window.
- It crosses the left or right viewport boundary.
- Its visible intersection with the viewport has positive width and height.

The following are never targets:

- floating, pinned, hidden, or unmapped windows;
- windows on inactive or special workspaces;
- fully hidden windows with no visible fragment;
- fully visible windows;
- popups, menus, tooltips, drag icons, or anonymous XWayland helper surfaces;
- any window while the workspace is in an incompatible fullscreen state.

## Target resolution

- Each monitor resolves targets independently.
- At most one target exists on the left and one on the right.
- If multiple windows cross the same boundary, choose the fragment belonging to
  the window nearest that boundary in tape order.
- The target rectangle is exactly the fragment's visible intersection with the
  viewport. It must not extend invisibly over gaps, unrelated windows, another
  monitor, or empty desktop space.
- The target is tied to a stable window identity, not to a side or a transient
  geometry rectangle.

## Interaction states

### Rest

- Nothing is drawn.
- No permanent button, rail, hotspot, border, or shadow is visible.
- Desktop and application input outside eligible fragments is completely
  untouched.

### Hover

- Entering a target starts reveal in the same frame; there is no hover delay.
- A centered chevron points toward the hidden part of the selected window.
- A subtle directional wash distinguishes the fragment as one large click
  target.
- The pointer shape remains the desktop's configured default pointer.
- Merely hovering does not focus, move, resize, or reorder anything.

### Press

- The primary-button press may strengthen the neutral wash slightly.
- The chevron does not jump, resize, acquire a container, or change color.
- Pressing never warps or confines the pointer.

### Activate

- A primary click anywhere in the fragment selects the exact represented
  window.
- The click is consumed as navigation and must not also activate application
  content underneath it.
- Hyprland focuses the selected window and lets the scrolling layout bring it
  into view.
- Focus must not be stolen back by content that moves beneath a stationary
  pointer.
- One click causes one focus transition and one tape movement.

### Settle and handoff

- The selected window remains the interaction identity throughout layout
  animation, even while its fragment changes size or position.
- Geometry, hit regions, hover identity, and rendering update atomically.
- Transient compositor enter/leave events caused by geometry or input-region
  commits must not be interpreted as physical pointer movement.
- Once the selected window is no longer clipped, its cue disappears.
- If the settled tape leaves a new eligible fragment beneath the stationary
  pointer, the cue hands off directly to that fragment without a blank frame,
  flash, duplicate arrow, or focus change.
- If no eligible fragment remains beneath the pointer, the cue fades out.
- The next click is accepted only against the settled, currently displayed
  target.

## Appearance

The cue has two elements and no container.

### Chevron

- Shape: a thin two-stroke chevron.
- Size: approximately 9 px wide by 18 px tall.
- Stroke: approximately 2.6 px with round caps and joins.
- Color: cool white, approximately `rgba(245, 248, 255, 0.92)`.
- Position: centered in the complete visible fragment.
- Direction: left for a left-clipped window, right for a right-clipped window.

### Directional wash

- Color: neutral charcoal, approximately `rgb(7, 10, 16)`.
- Strongest edge opacity: approximately `0.34`.
- Middle opacity near 58%: approximately `0.08`.
- Interior opacity: approximately `0.02`.
- Direction: strongest at the monitor boundary, fading toward the viewport
  interior.
- Press feedback may multiply the strongest opacity by approximately `1.15`.

### Explicit exclusions

There are no:

- drop shadows or glows;
- pills, circles, squares, or rounded panels;
- visible sensor rails;
- borders or accent-color gradients;
- labels, tooltips, counters, or navigation dots;
- persistent arrows;
- compositor blur behind the cue.

## Motion

- Reveal and hide use an approximately 80 ms ease-out opacity transition.
- Reveal begins immediately and must not wait for an IPC debounce.
- The chevron has no independent positional, scaling, spring, or bounce
  animation.
- Normal Hyprland tape motion remains responsible for moving windows.
- Reconciliation during tape motion must not restart the reveal animation.
- A target handoff may crossfade, but must never fade to zero between two valid
  targets beneath the pointer.

## Input and focus rules

- The physical pointer position is invariant across activation.
- Keyboard focus follows the selected window.
- Pointer focus must not reselect a window solely because layout animation moved
  that window beneath a stationary pointer.
- Normal follow-mouse behavior may resume after genuine physical pointer
  movement crosses a window boundary.
- No invisible full-monitor surface may intercept input.
- Secondary click, scrolling, dragging, and application input outside a target
  behave exactly as they do without the feature.
- Keyboard tape navigation remains fully independent and operational.

## Multiple monitors and workspaces

- Each monitor has its own viewport and up to two targets.
- A target can navigate only within the workspace visible on its monitor.
- Coordinates are evaluated in Hyprland logical space, including monitor scale
  and transform.
- Crossing monitor boundaries must not create overlapping targets.
- Switching a workspace invalidates its old targets atomically.
- Disconnecting, reconnecting, rotating, scaling, or reconfiguring a monitor
  must not leave stale input regions or surfaces.

## Accessibility

- The fragment is a large target; the chevron is not the hit target.
- The feature takes no keyboard focus and does not alter the tab order.
- An assistive-technology representation, if provided, identifies the action
  and direction without exposing implementation-only surfaces.
- The visible cue is supplemental. Keyboard navigation remains the accessible,
  deterministic alternative.

## Reliability requirements

- Exactly one live feature instance may own interaction state.
- A target either exists visually and interactively or does not exist at all.
  Rendering and input must never disagree.
- Repeated window-title events must not reset hover or animation.
- No surface is created, destroyed, or resized in response to ordinary pointer
  motion.
- No subprocess is spawned at frame rate.
- The model is event-driven, with an authoritative reconciliation after layout
  changes.
- Missing or reconnecting IPC must fail closed: no cue and no intercepted
  input.
- XWayland and native Wayland application windows behave identically because
  selection is based on compositor window geometry.

## Known Hyprland and Wayland hazards

Any future implementation must explicitly handle these rather than patching
their symptoms:

- Changing a Wayland surface's input region can generate pointer enter/leave
  events even when the physical pointer did not move.
- Hyprland's scrolling animation produces transitional geometry and multiple
  IPC events for one logical navigation.
- With `follow_mouse = 1`, automatic mouse refocus can undo focus when the tape
  moves windows beneath a stationary pointer. The desktop therefore keeps
  `input.mouse_refocus = false`.
- Gesture-level cursor snapping is independent of the general no-warp setting.
  The desktop therefore keeps `gestures.scrolling.move_snap_cursor = false`.
- A Hyprland Lua configuration can observe and dispatch compositor state, but
  should not be assumed to provide a native interactive drawing surface.
- An application-layer overlay must never confuse compositor-driven surface
  changes with user intent.

## Implementation boundary

This specification deliberately leaves the technology open.

A future implementation is acceptable only if it can:

1. observe stable window identity and authoritative layout geometry;
2. render the cue without permanent desktop chrome;
3. expose exact fragment-shaped input regions;
4. consume target clicks without blocking unrelated input;
5. distinguish physical pointer motion from surface/input-region churn;
6. make focus, geometry, rendering, and input updates atomic.

A compositor-native implementation or narrowly scoped Hyprland plugin may be
the cleanest route if Hyprland exposes the required APIs. A layer-shell client
is acceptable only if it meets every reliability requirement. Lua alone is not
preferred unless its API gains first-class interactive surface support.

## Acceptance tests

The feature is not complete until all of these pass repeatedly:

1. Hover each left and right fragment from both the window side and monitor
   edge; reveal begins immediately every time.
2. Leave and re-enter without moving the tape; the cue never sticks or misses.
3. Click through at least ten adjacent windows in both directions without
   pointer movement, bounce-back focus, duplicate movement, or a missing cue.
4. Repeat while Hyprland window animation is enabled and disabled.
5. Resize columns, move windows, open and close windows, and change workspaces
   while hovering.
6. Test narrow fragments, fragments wider than half the viewport, and windows
   taller or shorter than the viewport.
7. Test both sides of every monitor, including different scales and transforms.
8. Test native Wayland and XWayland windows.
9. Enter and leave fullscreen while hovering.
10. Reload the Hyprland configuration and reconnect a monitor.
11. Crash or kill the implementation and verify the desktop immediately becomes
    fully interactive with no stale surfaces.
12. Verify that no activation changes the physical pointer coordinates.
13. Verify that clicks outside a visible fragment always reach the underlying
    application.
14. Verify that an activation click never reaches application content.

## Non-goals

- Reimplementing Hyprland's scrolling layout.
- Centering the active window.
- Navigating to completely hidden windows.
- Providing a scrollbar or overview.
- Showing permanent previous/next buttons.
- Overriding application cursors outside the target fragment.
- Moving, snapping, or warping the physical pointer.
- Shipping a partial implementation that is merely visually convincing.
