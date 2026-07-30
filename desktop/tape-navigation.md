# Tape edge navigation

## Purpose

The scrolling layout deliberately leaves parts of neighboring windows visible at
the monitor edges. Those clipped fragments are navigation affordances: they show
where more content exists and can be clicked to bring that window into view.

The feature supplements keyboard navigation. It does not alter Hyprland's
scrolling layout or focus policy.

## Behavior

- A target exists only where an inactive, mapped, tiled window crosses the left
  or right boundary of its workspace's monitor.
- The complete visible fragment of that clipped window is the pointer and click
  target.
- At most one target is exposed on each side of each monitor. If multiple
  windows cross one boundary, the window nearest that boundary wins.
- Hovering a target reveals a centered chevron pointing toward the hidden part
  of the window.
- Clicking anywhere in the target focuses that exact Hyprland window. The
  scrolling layout then brings it into view using its normal focus behavior.
- Moving the tape beneath a stationary pointer must not focus a different
  window and reverse the navigation.
- The physical pointer never moves as a side effect of navigation.
- The active window, floating windows, hidden or unmapped windows, and windows
  from other workspaces are never targets.
- Targets are disabled while the active workspace is fullscreen.
- Target geometry follows the active workspace independently on every monitor.
- When no clipped neighbor exists, nothing is drawn and no input is intercepted.

## Appearance

The feature has no persistent desktop chrome.

At rest, every target is visually transparent. Hover adds:

- a thin, cool-white chevron centered in the visible fragment;
- a very subtle charcoal directional wash, strongest at the clipped monitor
  boundary and fading into the window;
- an 80 ms fade between hidden and revealed states.

There are no shadows, pills, rounded panels, borders, tooltips, labels, or
colored accent decorations. Pressing the target may briefly strengthen the
neutral wash for click feedback.

## Interaction and accessibility

- Targets do not accept keyboard focus or interfere with keyboard shortcuts.
- The monitor surface exposes a generic clipped-window navigation name to
  accessibility tools.
- A click is consumed as navigation; after the window is brought into view,
  normal application interaction resumes.
- The target must correspond to content that is actually visible. Invisible
  edge sensors are not part of this design.

## Technical contract

- `desktop/home/bin/tape-edges` is a Wayland layer-shell client started from the
  Hyprland session.
- It owns one stable transparent layer surface per monitor.
- Each surface's Wayland input region contains only the current clipped-window
  rectangles. The rest of the monitor remains fully click-through.
- Surfaces are not recreated or resized during normal navigation.
- Hyprland IPC events trigger geometry reconciliation; repeated title events for
  an unchanged active window are ignored.
- `input.mouse_refocus` is disabled so the moving tape cannot steal focus from
  the selected window. Pointer focus still changes after the pointer actually
  crosses a window boundary.
- A runtime lock permits only one helper process.
- The implementation uses the X cursor theme configured by the desktop and does
  not request pointer warps.

## Non-goals

- Reimplementing the scrolling layout.
- Centering the active window.
- Showing permanent previous/next buttons.
- Navigating to fully hidden windows with no visible fragment.
- Overriding application content or application-specific pointer shapes outside
  a clipped target.
