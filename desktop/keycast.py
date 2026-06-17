#!/usr/bin/env python3
import json
import os
import re
import shutil
import signal
import subprocess
import threading
import time

import gi
import libevdev

gi.require_version("Gdk", "3.0")
gi.require_version("Gtk", "3.0")
from gi.repository import Gdk, GLib, Gtk, Pango


TITLE = "Keycast"
TEXT_TIMEOUT = 4200
COMBO_TIMEOUT = 1400
TEXT_EXPIRY = TEXT_TIMEOUT / 1000
FADED_CLASS = "covered"
POINTER_POLL_MS = 160
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


class Keycast:
    def __init__(self):
        self.proc = None
        self.pressed = set()
        self.paused = False
        self.alt_latch = False
        self.caps = False
        self.text = ""
        self.last_text_at = 0
        self.bounds = None
        self.faded = False
        self.poll_count = 0
        self.serial = 0

        self.label = Gtk.Label(label="waiting for keys")
        self.label.set_name("keys")
        self.label.set_hexpand(True)
        self.label.set_ellipsize(Pango.EllipsizeMode.START)
        self.label.set_margin_top(16)
        self.label.set_margin_bottom(16)
        self.label.set_margin_start(24)
        self.label.set_margin_end(24)

        self.window = Gtk.Window(title=TITLE)
        self.window.set_decorated(not self.in_hyprland())
        self.window.set_default_size(640, 96)
        self.window.set_keep_above(True)
        self.window.set_accept_focus(False)
        self.window.set_focus_on_map(False)
        self.window.set_skip_taskbar_hint(True)
        self.window.set_skip_pager_hint(True)
        self.window.set_type_hint(Gdk.WindowTypeHint.UTILITY)
        self.window.connect("realize", self.make_click_through)
        self.window.connect("destroy", self.quit)
        self.window.add(self.label)

        css = b"""
        window {
          background: rgba(5,3,0,0.88);
          border: 2px solid #5a340b;
        }
        window.covered {
          background: rgba(5,3,0,0.62);
          border-color: rgba(90,52,11,0.62);
        }
        #keys {
          color: #ffb84d;
          text-shadow: 0 0 7px rgba(255,184,77,0.55);
          font: 36px "Fira Code", "DejaVu Sans Mono", "Noto Sans Mono", monospace;
          font-weight: 700;
        }
        window.covered #keys {
          color: rgba(255,184,77,0.62);
          text-shadow: none;
        }
        """
        provider = Gtk.CssProvider()
        provider.load_from_data(css)
        Gtk.StyleContext.add_provider_for_screen(
            self.window.get_screen(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

    def in_hyprland(self):
        return bool(
            os.environ.get("HYPRLAND_INSTANCE_SIGNATURE") and shutil.which("hyprctl")
        )

    def focused_monitor(self):
        try:
            output = subprocess.check_output(["hyprctl", "monitors", "-j"], text=True)
            return next(
                (monitor["name"] for monitor in json.loads(output) if monitor.get("focused")),
                None,
            )
        except Exception:
            return None

    def setup_hyprland(self):
        if not self.in_hyprland():
            return
        monitor = os.environ.get("KEYCAST_MONITOR") or self.focused_monitor()
        monitor_rule = f"monitor {monitor}, " if monitor else ""
        rule = (
            f"match:title ^({TITLE})$, {monitor_rule}"
            "float on, pin on, decorate on, no_focus on, no_shadow off, "
            "no_initial_focus on, no_blur on, no_anim on, rounding 7, "
            "border_size 1, border_color rgb(5a340b), size 760 96, "
            "move ((monitor_w-window_w)/2) (monitor_h-window_h-80)"
        )
        subprocess.run(
            ["hyprctl", "keyword", "windowrule", rule],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )

    def make_click_through(self, *_):
        self.window.get_window().set_pass_through(True)

    def hypr_json(self, *args):
        try:
            return json.loads(subprocess.check_output(["hyprctl", *args], text=True))
        except Exception:
            return None

    def update_bounds(self):
        clients = self.hypr_json("clients", "-j")
        if not clients:
            return
        for client in clients:
            if client.get("title") == TITLE and client.get("pid") == os.getpid():
                x, y = client["at"]
                width, height = client["size"]
                self.bounds = (x, y, x + width, y + height)
                return

    def set_faded(self, faded):
        if faded == self.faded:
            return
        self.faded = faded
        styles = self.window.get_style_context()
        if faded:
            styles.add_class(FADED_CLASS)
        else:
            styles.remove_class(FADED_CLASS)
        self.window.queue_draw()

    def fade_near_pointer(self):
        if not self.in_hyprland():
            return False
        self.poll_count += 1
        if self.bounds is None or self.poll_count % 8 == 0:
            self.update_bounds()
        pos = self.hypr_json("cursorpos", "-j")
        if self.bounds and pos:
            x1, y1, x2, y2 = self.bounds
            covered = x1 <= pos["x"] <= x2 and y1 <= pos["y"] <= y2
            self.set_faded(covered)
        return True

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
        self.show(visible, TEXT_TIMEOUT)

    def expire_text_if_idle(self):
        if self.text and time.monotonic() - self.last_text_at > TEXT_EXPIRY:
            self.text = ""

    def toggle_pause(self):
        self.paused = not self.paused
        self.text = ""
        self.show("PAUSED" if self.paused else "LIVE", 900)

    def handle(self, code, state):
        if state != "pressed":
            self.pressed.discard(code)
            if code in {"KEY_LEFTALT", "KEY_RIGHTALT"}:
                self.alt_latch = False
            return

        self.pressed.add(code)
        if code == "KEY_CAPSLOCK":
            self.caps = not self.caps
            self.text = ""
            if not self.paused:
                self.show("CAPSLOCK", COMBO_TIMEOUT)
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
        self.show(self.combo(code), COMBO_TIMEOUT)

    def read_libinput(self):
        for line in self.proc.stdout:
            if match := NAMED_EVENT.search(line):
                code, state = match.groups()
            elif match := NUMBERED_EVENT.search(line):
                code, state = self.code_from_number(match.group(1)), match.group(2)
            else:
                continue
            GLib.idle_add(self.handle, code, state)

    def run(self):
        self.setup_hyprland()
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
        self.window.show_all()
        GLib.timeout_add(POINTER_POLL_MS, self.fade_near_pointer)
        Gtk.main()

    def quit(self, *_):
        if self.proc and self.proc.poll() is None:
            self.proc.send_signal(signal.SIGINT)
        Gtk.main_quit()


if __name__ == "__main__":
    Keycast().run()
