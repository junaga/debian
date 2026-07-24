-- https://wiki.hypr.land/Configuring/

local pointer = os.getenv("HOME")
    .. "/.local/lib/hyprland/plugins/windows-pointer-linux.so"

hl.plugin.load(pointer)

require("core.windows")
require("style")

require("core.start")
screenshot = [[grim -g "$(slurp -d)" - | wl-copy]]
terminal = "crtty --shader ~/.config/crtty/amber-crt.glsl"
explorer = "dolphin"
browser = "google-chrome-stable"
require("keys")

function autostart()
    hl.exec_cmd(browser)
    hl.exec_cmd("steam")
    hl.exec_cmd("discord")
end

hl.on("hyprland.start", autostart)
