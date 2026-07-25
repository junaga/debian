-- https://wiki.hypr.land/Configuring/

require("core.windows")
require("style")

require("core.start")
screenshot = [[grim -g "$(slurp -d)" - | wl-copy]]
terminal = "kitty"
music = "youtube-music"
explorer = "dolphin"
browser = "google-chrome-stable"
require("keys")

function autostart()
    hl.exec_cmd(browser)
    hl.exec_cmd("steam")
    hl.exec_cmd("discord")
end

hl.on("hyprland.start", autostart)
