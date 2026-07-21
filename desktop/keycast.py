#!/usr/bin/env python3
import fcntl
import json
import math
import os
import re
import shutil
import signal
import socket
import subprocess
import threading
import time
from dataclasses import dataclass
from pathlib import Path

import cairo


def runtime_path(name):
    runtime_dir = Path(os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}"))
    return runtime_dir / "keycast" / name


def interaction_active(meta_held, pointer_inside, dragging=False):
    return dragging or (meta_held and pointer_inside)

import gi
import libevdev

gi.require_foreign("cairo")
gi.require_version("Gdk", "3.0")
gi.require_version("Gtk", "3.0")
try:
    gi.require_version("GtkLayerShell", "0.1")
    from gi.repository import GtkLayerShell
except (ImportError, ValueError):
    GtkLayerShell = None

from gi.repository import Gdk, GLib, Gtk, Pango


TITLE = "Keycast"
CONTROL_TITLE = "Keycast Control"
DISPLAY_WIDTH = 760
DISPLAY_HEIGHT = 96
TEXT_DISPLAY_MS = 4200
WORD_IDLE_RESET_MS = 1800
COMBO_DISPLAY_MS = 1400
WORD_IDLE_RESET_SECONDS = WORD_IDLE_RESET_MS / 1000
DRAG_POLL_MS = 70
POINTER_POLL_MS = 70
GRID_COLUMNS = 3
GRID_ROWS = 5
GRID_MARGIN = 20
META_KEYS = {"KEY_LEFTMETA", "KEY_RIGHTMETA"}
MODS = {
    "KEY_LEFTCTRL": "CTRL",
    "KEY_RIGHTCTRL": "CTRL",
    "KEY_LEFTALT": "ALT",
    "KEY_RIGHTALT": "ALT",
    "KEY_LEFTSHIFT": "SHIFT",
    "KEY_RIGHTSHIFT": "SHIFT",
    "KEY_LEFTMETA": "META",
    "KEY_RIGHTMETA": "META",
}
SHIFT_KEYS = {"KEY_LEFTSHIFT", "KEY_RIGHTSHIFT"}
MOD_CODES = set(MODS)
CHORD_MODS = MOD_CODES - SHIFT_KEYS
PUNCT = {
    "KEY_SPACE": (" ", " "),
    "KEY_1": ("1", "!"),
    "KEY_2": ("2", "@"),
    "KEY_3": ("3", "#"),
    "KEY_4": ("4", "$"),
    "KEY_5": ("5", "%"),
    "KEY_6": ("6", "^"),
    "KEY_7": ("7", "&"),
    "KEY_8": ("8", "*"),
    "KEY_9": ("9", "("),
    "KEY_0": ("0", ")"),
    "KEY_MINUS": ("-", "_"),
    "KEY_EQUAL": ("=", "+"),
    "KEY_LEFTBRACE": ("[", "{"),
    "KEY_RIGHTBRACE": ("]", "}"),
    "KEY_BACKSLASH": ("\\", "|"),
    "KEY_SEMICOLON": (";", ":"),
    "KEY_APOSTROPHE": ("'", '"'),
    "KEY_GRAVE": ("`", "~"),
    "KEY_COMMA": (",", "<"),
    "KEY_DOT": (".", ">"),
    "KEY_SLASH": ("/", "?"),
}
NAMED_EVENT = re.compile(r"\b(KEY_[A-Z0-9_]+)\b.*\b(pressed|released)\b")
NUMBERED_EVENT = re.compile(r"\s(\d+)\s+\(\d+\)\s+(pressed|released)\b")
LEFT_BUTTON_EVENT = re.compile(
    r"\bBTN_LEFT\b(?:\s+\(\d+\))?.*\b(pressed|released)\b"
)


@dataclass(frozen=True)
class Rect:
    x: int
    y: int
    width: int
    height: int

    @property
    def center(self):
        return self.x + self.width / 2, self.y + self.height / 2

    def contains(self, x, y):
        return self.x <= x <= self.x + self.width and self.y <= y <= self.y + self.height


@dataclass(frozen=True)
class Monitor:
    id: int
    name: str
    bounds: Rect
    workarea: Rect
    focused: bool = False


@dataclass(frozen=True)
class SnapTarget:
    monitor: Monitor
    column: int
    row: int
    rect: Rect


def monitor_for_rect(rect, monitors):
    if not monitors:
        return None
    x, y = rect.center
    containing = next(
        (monitor for monitor in monitors if monitor.bounds.contains(x, y)), None
    )
    if containing:
        return containing
    return min(monitors, key=lambda monitor: math.dist((x, y), monitor.bounds.center))


def gdk_monitor_for(monitor, fallback_index=0):
    display = Gdk.Display.get_default()
    if not display or not monitor:
        return None
    for index in range(display.get_n_monitors()):
        candidate = display.get_monitor(index)
        bounds = candidate.get_geometry()
        if bounds.x == monitor.bounds.x and bounds.y == monitor.bounds.y:
            return candidate
    if fallback_index < display.get_n_monitors():
        return display.get_monitor(fallback_index)
    return None


def make_input_transparent(widget, *_):
    if not widget.get_realized():
        return False
    window = widget.get_window()
    window.input_shape_combine_region(cairo.Region(), 0, 0)
    window.set_pass_through(True)
    window.get_display().flush()
    return False


class GridGeometry:
    def __init__(self, columns=GRID_COLUMNS, rows=GRID_ROWS, margin=GRID_MARGIN):
        self.columns = max(1, columns)
        self.rows = max(1, rows)
        self.margin = max(0, margin)

    def targets(self, monitor, window_size):
        width, height = window_size
        area = monitor.workarea
        left = area.x + self.margin
        top = area.y + self.margin
        usable_width = max(width, area.width - 2 * self.margin)
        usable_height = max(height, area.height - 2 * self.margin)
        max_x = left + usable_width - width
        max_y = top + usable_height - height
        targets = []
        seen = set()
        for row in range(self.rows):
            center_y = top + usable_height * (row + 0.5) / self.rows
            y = min(max(round(center_y - height / 2), top), max_y)
            for column in range(self.columns):
                center_x = left + usable_width * (column + 0.5) / self.columns
                x = min(max(round(center_x - width / 2), left), max_x)
                if (x, y) in seen:
                    continue
                seen.add((x, y))
                targets.append(
                    SnapTarget(monitor, column, row, Rect(x, y, width, height))
                )
        return targets

    def nearest(self, rect, monitors):
        candidates = [
            target
            for monitor in monitors
            for target in self.targets(monitor, (rect.width, rect.height))
        ]
        if not candidates:
            return None
        x, y = rect.center
        return min(
            candidates,
            key=lambda target: math.dist((x, y), target.rect.center),
        )


class HyprlandClient:
    def __init__(self):
        runtime_dir = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
        signature = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE", "")
        self.socket_path = Path(runtime_dir) / "hypr" / signature / ".socket.sock"

    @property
    def available(self):
        return bool(os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")) and self.socket_path.exists()

    def request(self, request):
        if not self.available:
            return None
        connection = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        try:
            connection.settimeout(0.5)
            connection.connect(str(self.socket_path))
            connection.sendall(request.encode())
            connection.shutdown(socket.SHUT_WR)
            chunks = []
            while chunk := connection.recv(65536):
                chunks.append(chunk)
            return b"".join(chunks).decode()
        except OSError:
            return None
        finally:
            connection.close()

    def json(self, command):
        try:
            response = self.request(f"j/{command}")
            return json.loads(response) if response else None
        except (json.JSONDecodeError, TypeError):
            return None

    def clients(self):
        return self.json("clients") or []

    def cursor(self):
        return self.json("cursorpos")

    def monitors(self):
        result = []
        for item in self.json("monitors") or []:
            reserved = item.get("reserved", [0, 0, 0, 0])
            left, top, right, bottom = (reserved + [0, 0, 0, 0])[:4]
            bounds = Rect(item["x"], item["y"], item["width"], item["height"])
            workarea = Rect(
                bounds.x + left,
                bounds.y + top,
                max(1, bounds.width - left - right),
                max(1, bounds.height - top - bottom),
            )
            result.append(
                Monitor(item["id"], item["name"], bounds, workarea, item.get("focused", False))
            )
        return result

    def window_for_pid(self, pid, title=None):
        return next(
            (
                client
                for client in self.clients()
                if client.get("pid") == pid
                and (
                    title is None
                    or client.get("title") == title
                    or client.get("initialTitle") == title
                )
            ),
            None,
        )

    def active_window(self):
        return self.json("activewindow") or {}

    def dispatch(self, dispatcher, arguments=""):
        request = f"dispatch {dispatcher} {arguments}".rstrip()
        response = self.request(request)
        return bool(response and response.strip() == "ok")

    def move_window(self, address, x, y):
        return self.dispatch(
            "movewindowpixel", f"exact {int(x)} {int(y)},address:{address}"
        )

    def focus_window(self, address):
        return self.dispatch("focuswindow", f"address:{address}")


class StateStore:
    def __init__(self):
        state_root = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state"))
        self.path = state_root / "keycast" / "position.json"

    def load(self):
        try:
            return json.loads(self.path.read_text())
        except (OSError, json.JSONDecodeError):
            return None

    def save(self, target, geometry):
        self.path.parent.mkdir(parents=True, exist_ok=True)
        temporary = self.path.with_suffix(".tmp")
        temporary.write_text(
            json.dumps(
                {
                    "monitor": target.monitor.name,
                    "column": target.column,
                    "row": target.row,
                    "grid": [geometry.columns, geometry.rows],
                },
                indent=2,
            )
            + "\n"
        )
        temporary.replace(self.path)


class GridOverlay:
    def __init__(self, geometry):
        self.geometry = geometry
        self.windows = []
        self.selected = None

    @property
    def supported(self):
        return GtkLayerShell is not None and GtkLayerShell.is_supported()

    def show(self, monitors, selected=None):
        if not self.supported:
            return
        self.hide()
        self.selected = selected
        for index, monitor in enumerate(monitors):
            gdk_monitor = gdk_monitor_for(monitor, index)
            if not gdk_monitor:
                continue
            window = Gtk.Window()
            window.set_name("keycast-grid")
            window.set_app_paintable(True)
            visual = window.get_screen().get_rgba_visual()
            if visual:
                window.set_visual(visual)
            canvas = Gtk.DrawingArea()
            canvas.connect("draw", self._draw, monitor)
            window.add(canvas)
            GtkLayerShell.init_for_window(window)
            GtkLayerShell.set_namespace(window, "keycast-grid")
            GtkLayerShell.set_layer(window, GtkLayerShell.Layer.OVERLAY)
            GtkLayerShell.set_monitor(window, gdk_monitor)
            GtkLayerShell.set_keyboard_mode(window, GtkLayerShell.KeyboardMode.NONE)
            GtkLayerShell.set_exclusive_zone(window, 0)
            for edge in (
                GtkLayerShell.Edge.TOP,
                GtkLayerShell.Edge.BOTTOM,
                GtkLayerShell.Edge.LEFT,
                GtkLayerShell.Edge.RIGHT,
            ):
                GtkLayerShell.set_anchor(window, edge, True)
            window.connect("realize", make_input_transparent)
            window.connect("map-event", make_input_transparent)
            window.connect("size-allocate", make_input_transparent)
            window.show_all()
            self.windows.append(window)

    def update(self, monitors, selected):
        if self.selected == selected:
            return
        self.selected = selected
        for window in self.windows:
            window.queue_draw()

    def hide(self):
        for window in self.windows:
            window.destroy()
        self.windows.clear()
        self.selected = None

    def _draw(self, widget, context, monitor):
        width = widget.get_allocated_width()
        height = widget.get_allocated_height()
        context.set_source_rgba(1.0, 0.72, 0.3, 0.28)
        context.set_line_width(1)
        for column in range(1, self.geometry.columns):
            x = round(width * column / self.geometry.columns) + 0.5
            context.move_to(x, 0)
            context.line_to(x, height)
        for row in range(1, self.geometry.rows):
            y = round(height * row / self.geometry.rows) + 0.5
            context.move_to(0, y)
            context.line_to(width, y)
        context.stroke()

        selected = self.selected
        if selected and selected.monitor.name == monitor.name:
            cell_x = width * selected.column / self.geometry.columns
            cell_y = height * selected.row / self.geometry.rows
            cell_width = width / self.geometry.columns
            cell_height = height / self.geometry.rows
            context.set_source_rgba(1.0, 0.72, 0.3, 0.13)
            context.rectangle(cell_x, cell_y, cell_width, cell_height)
            context.fill()

            rect = selected.rect
            context.set_source_rgba(1.0, 0.72, 0.3, 0.8)
            context.set_line_width(3)
            context.rectangle(
                rect.x - monitor.bounds.x,
                rect.y - monitor.bounds.y,
                rect.width,
                rect.height,
            )
            context.stroke()
        return False


class Keycast:
    def __init__(self):
        self.proc = None
        self.hypr = HyprlandClient()
        self.layer_mode = bool(
            self.hypr.available
            and GtkLayerShell is not None
            and GtkLayerShell.is_supported()
        )
        self.geometry = GridGeometry()
        self.state = StateStore()
        self.overlay = GridOverlay(self.geometry)
        self.pressed = set()
        self.paused = False
        self.alt_latch = False
        self.caps = False
        self.text = ""
        self.last_text_at = 0
        self.serial = 0
        self.interactive = False
        self.dragging = False
        self.previous_focus = None
        self.selected_target = None
        self.display_rect = Rect(0, 0, DISPLAY_WIDTH, DISPLAY_HEIGHT)
        self.display_monitor = None
        self.control_window = None
        self.control_address = None
        self.disarming_control = False
        self.quitting = False

        self.label = Gtk.Label(label="waiting for keys")
        self.label.set_name("keys")
        self.label.set_hexpand(True)
        self.label.set_ellipsize(Pango.EllipsizeMode.START)
        self.label.set_margin_top(16)
        self.label.set_margin_bottom(16)
        self.label.set_margin_start(24)
        self.label.set_margin_end(24)

        self.window = Gtk.Window(title=TITLE)
        self.window.set_name("keycast-display")
        self.window.set_decorated(not self.layer_mode)
        self.window.set_default_size(DISPLAY_WIDTH, DISPLAY_HEIGHT)
        self.window.set_size_request(DISPLAY_WIDTH, DISPLAY_HEIGHT)
        self.window.set_keep_above(True)
        self.window.set_accept_focus(False)
        self.window.set_focus_on_map(False)
        self.window.set_skip_taskbar_hint(True)
        self.window.set_skip_pager_hint(True)
        self.window.set_type_hint(Gdk.WindowTypeHint.UTILITY)
        self.window.connect("destroy", self.quit)
        self.window.add(self.label)

        if self.layer_mode:
            GtkLayerShell.init_for_window(self.window)
            GtkLayerShell.set_namespace(self.window, "keycast")
            GtkLayerShell.set_layer(self.window, GtkLayerShell.Layer.TOP)
            GtkLayerShell.set_keyboard_mode(
                self.window, GtkLayerShell.KeyboardMode.NONE
            )
            GtkLayerShell.set_exclusive_zone(self.window, 0)
            GtkLayerShell.set_anchor(self.window, GtkLayerShell.Edge.TOP, True)
            GtkLayerShell.set_anchor(self.window, GtkLayerShell.Edge.LEFT, True)
            GtkLayerShell.set_anchor(self.window, GtkLayerShell.Edge.BOTTOM, False)
            GtkLayerShell.set_anchor(self.window, GtkLayerShell.Edge.RIGHT, False)
            self.window.connect("realize", make_input_transparent)
            self.window.connect("map-event", make_input_transparent)
            self.window.connect("size-allocate", make_input_transparent)

        css = b"""
        #keycast-display {
          background: rgba(5,3,0,0.88);
          border: 2px solid #5a340b;
        }
        #keycast-display.armed {
          background: rgba(18,9,0,0.96);
          border-color: #ffb84d;
        }
        #keys {
          color: #ffb84d;
          text-shadow: 0 0 7px rgba(255,184,77,0.55);
          font: 36px "Fira Code", "DejaVu Sans Mono", "Noto Sans Mono", monospace;
          font-weight: 700;
        }
        #keycast-display.armed #keys {
          color: #ffd08a;
          text-shadow: 0 0 10px rgba(255,184,77,0.8);
        }
        #keycast-control {
          background: transparent;
          border: none;
        }
        #keycast-grid {
          background: transparent;
          border: none;
        }
        """
        provider = Gtk.CssProvider()
        provider.load_from_data(css)
        Gtk.StyleContext.add_provider_for_screen(
            self.window.get_screen(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

    def in_hyprland(self):
        return self.hypr.available

    def prepare_display_position(self):
        monitors = self.hypr.monitors()
        if not monitors:
            return
        saved = self.state.load() or {}
        monitor = next(
            (item for item in monitors if item.name == saved.get("monitor")),
            next((item for item in monitors if item.focused), monitors[0]),
        )
        column = saved.get("column", self.geometry.columns // 2)
        row = saved.get("row", self.geometry.rows - 1)
        targets = self.geometry.targets(monitor, (DISPLAY_WIDTH, DISPLAY_HEIGHT))
        target = next(
            (
                item
                for item in targets
                if item.column == column and item.row == row
            ),
            targets[0],
        )
        self.move_display(target.rect, target.monitor)

    def move_display(self, rect, monitor=None):
        self.display_rect = rect
        monitors = self.hypr.monitors() if monitor is None else []
        monitor = monitor or monitor_for_rect(rect, monitors)
        if not monitor:
            return
        self.display_monitor = monitor
        if not self.layer_mode:
            return
        gdk_monitor = gdk_monitor_for(monitor, monitor.id)
        if gdk_monitor:
            GtkLayerShell.set_monitor(self.window, gdk_monitor)
        GtkLayerShell.set_margin(
            self.window, GtkLayerShell.Edge.LEFT, rect.x - monitor.bounds.x
        )
        GtkLayerShell.set_margin(
            self.window, GtkLayerShell.Edge.TOP, rect.y - monitor.bounds.y
        )

    def create_control(self):
        if self.control_window or not self.layer_mode:
            return
        window = Gtk.Window(title=CONTROL_TITLE)
        window.set_name("keycast-control")
        window.set_decorated(False)
        window.set_app_paintable(True)
        visual = window.get_screen().get_rgba_visual()
        if visual:
            window.set_visual(visual)
        window.set_default_size(DISPLAY_WIDTH, DISPLAY_HEIGHT)
        window.set_size_request(DISPLAY_WIDTH, DISPLAY_HEIGHT)
        window.set_accept_focus(True)
        window.set_focus_on_map(False)
        window.set_skip_taskbar_hint(True)
        window.set_skip_pager_hint(True)
        window.set_type_hint(Gdk.WindowTypeHint.UTILITY)
        window.connect("map-event", self.control_mapped)
        window.connect("destroy", self.control_destroyed)
        self.control_window = window
        window.show_all()

    def control_mapped(self, window, *_):
        GLib.idle_add(self.place_control, window, 0)
        return False

    def place_control(self, window, attempt):
        if window is not self.control_window or not self.interactive:
            return False
        client = self.hypr.window_for_pid(os.getpid(), CONTROL_TITLE)
        if not client:
            if attempt < 20:
                GLib.timeout_add(25, self.place_control, window, attempt + 1)
            return False
        self.control_address = client.get("address")
        if self.control_address:
            self.hypr.move_window(
                self.control_address, self.display_rect.x, self.display_rect.y
            )
            self.hypr.focus_window(self.control_address)
        return False

    def destroy_control(self):
        window = self.control_window
        if not window:
            return
        self.disarming_control = True
        self.control_window = None
        self.control_address = None
        window.destroy()
        self.disarming_control = False

    def control_destroyed(self, window):
        intentionally_disarmed = self.disarming_control
        if window is self.control_window:
            self.control_window = None
        self.control_address = None
        if not intentionally_disarmed and not self.quitting:
            self.interactive = False
            self.quit()

    def set_interactive(self, interactive):
        if interactive == self.interactive:
            return
        self.interactive = interactive
        styles = self.window.get_style_context()
        if interactive:
            active = self.hypr.active_window()
            self.previous_focus = active.get("address")
            styles.add_class("armed")
            self.create_control()
        else:
            styles.remove_class("armed")
            self.destroy_control()
            self.restore_focus()
            if not self.dragging:
                self.overlay.hide()
        self.window.queue_draw()

    def pointer_inside(self):
        cursor = self.hypr.cursor()
        return bool(
            cursor and self.display_rect.contains(cursor["x"], cursor["y"])
        )

    def refresh_interaction(self):
        meta_held = bool(self.pressed & META_KEYS)
        hovered = self.pointer_inside() if meta_held and not self.dragging else False
        self.set_interactive(interaction_active(meta_held, hovered, self.dragging))
        return True

    def restore_focus(self):
        active = self.hypr.active_window()
        if (
            self.previous_focus
            and active.get("pid") == os.getpid()
            and active.get("address") != self.previous_focus
        ):
            self.hypr.focus_window(self.previous_focus)
        self.previous_focus = None

    def control_rect(self, client=None):
        client = client or self.hypr.window_for_pid(os.getpid(), CONTROL_TITLE)
        if not client:
            return None
        self.control_address = client.get("address")
        return Rect(client["at"][0], client["at"][1], client["size"][0], client["size"][1])

    def begin_drag(self):
        client = self.hypr.window_for_pid(os.getpid(), CONTROL_TITLE)
        cursor = self.hypr.cursor()
        rect = self.control_rect(client)
        if not rect or not cursor or not rect.contains(cursor["x"], cursor["y"]):
            return
        self.dragging = True
        self.set_interactive(True)
        monitors = self.hypr.monitors()
        self.selected_target = self.geometry.nearest(rect, monitors)
        self.overlay.show(monitors, self.selected_target)

    def poll_drag(self):
        if not self.dragging:
            return True
        rect = self.control_rect()
        monitors = self.hypr.monitors()
        if rect and monitors:
            self.move_display(rect, monitor_for_rect(rect, monitors))
            self.selected_target = self.geometry.nearest(rect, monitors)
            self.overlay.update(monitors, self.selected_target)
        return True

    def finish_drag(self):
        if not self.dragging:
            return
        self.poll_drag()
        target = self.selected_target
        if target and self.control_address:
            self.hypr.move_window(
                self.control_address, target.rect.x, target.rect.y
            )
            self.move_display(target.rect, target.monitor)
            self.state.save(target, self.geometry)
        self.dragging = False
        self.selected_target = None
        self.overlay.hide()
        self.refresh_interaction()

    def show(self, text, timeout=1800):
        self.serial += 1
        serial = self.serial
        self.label.set_text(text)
        if timeout:
            GLib.timeout_add(timeout, self.clear, serial)

    def clear(self, serial):
        if serial == self.serial:
            self.label.set_text("")
        return False

    def pretty(self, code):
        return code.removeprefix("KEY_")

    def code_from_number(self, number):
        try:
            return libevdev.EventCode.from_type_and_code_value(
                libevdev.EV_KEY, int(number)
            ).name
        except Exception:
            return f"KEY_{number}"

    def combo(self, code):
        mods = []
        seen = set()
        for mod_code, mod_name in MODS.items():
            if mod_code in self.pressed and mod_name not in seen and mod_code != code:
                mods.append(mod_name)
                seen.add(mod_name)
        key = self.pretty(code)
        return "+".join(mods + [key]) if mods else key

    def shifted(self):
        return bool(self.pressed & SHIFT_KEYS)

    def control_combo_active(self):
        return bool(self.pressed & CHORD_MODS)

    def printable(self, code):
        if code.startswith("KEY_") and len(code) == 5 and code[-1].isalpha():
            char = code[-1].lower()
            return char.upper() if self.shifted() ^ self.caps else char
        if code in PUNCT:
            return PUNCT[code][self.shifted()]
        if code.startswith("KEY_") and len(code) == 5 and code[-1].isdigit():
            return code[-1]
        return None

    def show_text(self):
        self.last_text_at = time.monotonic()
        visible = self.text[-42:]
        self.show(visible, TEXT_DISPLAY_MS)

    def expire_text_if_idle(self):
        if (
            self.text
            and time.monotonic() - self.last_text_at > WORD_IDLE_RESET_SECONDS
        ):
            self.text = ""

    def toggle_pause(self):
        self.paused = not self.paused
        self.text = ""
        self.show("PAUSED" if self.paused else "LIVE", 900)

    def handle(self, code, state):
        if state != "pressed":
            self.pressed.discard(code)
            if code in META_KEYS:
                self.refresh_interaction()
            if code in {"KEY_LEFTALT", "KEY_RIGHTALT"}:
                self.alt_latch = False
            return

        self.pressed.add(code)
        if code in META_KEYS:
            self.refresh_interaction()
        if code == "KEY_CAPSLOCK":
            self.caps = not self.caps
            self.text = ""
            if not self.paused:
                self.show("CAPSLOCK", COMBO_DISPLAY_MS)
            return
        if {"KEY_LEFTALT", "KEY_RIGHTALT"} <= self.pressed and not self.alt_latch:
            self.alt_latch = True
            self.toggle_pause()
            return
        if self.paused or code in MOD_CODES:
            return

        self.expire_text_if_idle()
        char = None if self.control_combo_active() else self.printable(code)
        if char is not None:
            self.text = (self.text + char)[-160:]
            self.show_text()
            return
        self.text = ""
        self.show(self.combo(code), COMBO_DISPLAY_MS)

    def read_libinput(self):
        for line in self.proc.stdout:
            if match := LEFT_BUTTON_EVENT.search(line):
                GLib.idle_add(self.handle_left_button, match.group(1))
                continue
            if match := NAMED_EVENT.search(line):
                code, state = match.groups()
            elif match := NUMBERED_EVENT.search(line):
                code, state = self.code_from_number(match.group(1)), match.group(2)
            else:
                continue
            GLib.idle_add(self.handle, code, state)

    def handle_left_button(self, state):
        if state == "pressed" and self.pressed & META_KEYS and self.pointer_inside():
            self.begin_drag()
        elif state == "released" and self.dragging:
            self.finish_drag()
        return False

    def acquire_instance_lock(self):
        path = runtime_path("instance.lock")
        path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
        self.instance_lock = path.open("w")
        try:
            fcntl.flock(self.instance_lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return False
        self.instance_lock.write(str(os.getpid()))
        self.instance_lock.flush()
        return True

    def run(self):
        if not self.acquire_instance_lock():
            return
        if not shutil.which("libinput"):
            self.show("install: sudo apt install libinput-tools", 0)
        else:
            self.proc = subprocess.Popen(
                ["sudo", "libinput", "debug-events", "--show-keycodes"],
                stdout=subprocess.PIPE,
                text=True,
                bufsize=1,
            )
            threading.Thread(target=self.read_libinput, daemon=True).start()
        self.prepare_display_position()
        self.window.show_all()
        GLib.timeout_add(DRAG_POLL_MS, self.poll_drag)
        GLib.timeout_add(POINTER_POLL_MS, self.refresh_interaction)
        Gtk.main()

    def quit(self, *_):
        if self.quitting:
            return
        self.quitting = True
        self.overlay.hide()
        self.destroy_control()
        if self.proc and self.proc.poll() is None:
            self.proc.send_signal(signal.SIGINT)
        Gtk.main_quit()


if __name__ == "__main__":
    Keycast().run()
