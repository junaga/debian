-- https://wiki.hypr.land/Configuring/

require("core.motion")
require("desktop")

function autostart()
    hl.exec_cmd("google-chrome-stable")
    hl.exec_cmd("steam")
    hl.exec_cmd("discord")
end

hl.on("hyprland.start", autostart)
require("core.keys")
start = require("core.start")

screenshot = [[grim -g "$(slurp -d)" - | wl-copy]]
terminal = "kitty"
explorer = "dolphin"
browser = "google-chrome-stable"
music = "youtube-music"

exit("SUPER + SHIFT + W")
close("SUPER + W")
open("SUPER + R", start)
open("SUPER + P", screenshot)
open("SUPER + T", terminal, { scrolling_width = 0.395 })
open("SUPER + E", explorer)
open("SUPER + B", browser)
open("SUPER + M", music, { scrolling_width = 0.28 })

-- hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))
