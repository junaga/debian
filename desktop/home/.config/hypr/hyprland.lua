-- https://wiki.hypr.land/Configuring/

require("core.motion")
local open = require("core.keys")
require("desktop")

local screenshot = [[grim -g "$(slurp -d)" - | wl-copy]]
local terminal = "kitty --single-instance"
local explorer = "dolphin"
local browser = "google-chrome-stable"
local music = "youtube-music"
local steam = "steam -system-composer"
local discord = "discord --ozone-platform=wayland"
local chatgpt = "chatgpt"

open("SUPER + P", screenshot)
open("SUPER + T", terminal)
open("SUPER + E", explorer)
open("SUPER + B", browser)
open("SUPER + M", music)
open("SUPER + C", chatgpt)

local function autostart()
    hl.exec_cmd(browser)
    hl.exec_cmd(steam)
    hl.exec_cmd(discord)
    hl.exec_cmd(chatgpt)
end

hl.on("hyprland.start", autostart)
