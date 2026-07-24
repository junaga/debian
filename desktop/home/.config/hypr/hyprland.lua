-- https://wiki.hypr.land/Configuring/

require("windows")
terminal = "kitty"
explorer = "dolphin"
browser = "google-chrome-stable"
screenshot = [[grim -g "$(slurp -d)" - | wl-copy]]
require("keyboard")

function autostart()
    hl.exec_cmd(browser)
    hl.exec_cmd("steam")
    hl.exec_cmd("discord")
end

hl.on("hyprland.start", autostart)
