-- https://wiki.hypr.land/Configuring/

require("style")

terminal = "kitty"
explorer = "dolphin"
browser = "google-chrome-stable"

function autostart()
    hl.exec_cmd(browser)
    hl.exec_cmd("steam")
    hl.exec_cmd("discord")
end

hl.on("hyprland.start", autostart)

require("input")
