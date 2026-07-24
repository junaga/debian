-- https://wiki.hypr.land/Configuring/

require("windows")

screenshot = [[grim -g "$(slurp -d)" - | wl-copy]]
require("start")
terminal = "kitty"
explorer = "dolphin"
browser = "google-chrome-stable"
require("keyboard")

function autostart()
    hl.exec_cmd(browser)
    hl.exec_cmd("steam")
    hl.exec_cmd("discord")
end

hl.on("hyprland.start", autostart)
