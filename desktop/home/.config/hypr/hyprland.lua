-- https://wiki.hypr.land/Configuring/

require("core.motion")
local open = require("core.keys")
require("desktop")

local screenshot = [[grim -g "$(slurp -d)" - | wl-copy]]
local terminal = "kitty"
local explorer = "dolphin"
local browser = "google-chrome-stable"
local music = "youtube-music"
local steam = "steam -system-composer"
local discord = "discord"

open("SUPER + P", screenshot)
open("SUPER + T", terminal)
open("SUPER + E", explorer)
open("SUPER + B", browser)
open("SUPER + M", music)

local function autostart()
    hl.exec_cmd(browser)
    hl.exec_cmd(steam)
    hl.exec_cmd(discord)
end

hl.on("hyprland.start", autostart)
