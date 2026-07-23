-- Hyprland session configuration.
-- https://wiki.hypr.land/Configuring/Start/

require("style")
require("input")


-------------------
---- AUTOSTART ----
-------------------

-- Start session services and applications here.
-- hl.on("hyprland.start", function()
--     hl.exec_cmd("nm-applet")
--     hl.exec_cmd("waybar & hyprpaper & firefox")
-- end)


-----------------------
----- PERMISSIONS -----
-----------------------

-- Permission changes require a full Hyprland restart.
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/

-- hl.config({
--     ecosystem = {
--         enforce_permissions = true,
--     },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")
