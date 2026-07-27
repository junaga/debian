-- https://wiki.hypr.land/Configuring/

require("core.motion")
require("core.keys")
require("desktop")


screenshot = [[grim -g "$(slurp -d)" - | wl-copy]]
terminal = "kitty"
explorer = "dolphin"
browser = "google-chrome-stable"
music = "youtube-music"
steam = "steam -system-composer"
discord = "discord"

open("SUPER + P", screenshot)
open("SUPER + T", terminal)
open("SUPER + E", explorer)
open("SUPER + B", browser)
open("SUPER + M", music)


function autostart()
    hl.exec_cmd(browser)
    hl.exec_cmd(steam)
    hl.exec_cmd(discord)
end

hl.on("hyprland.start", autostart)
