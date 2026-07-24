-- Previous choices that have not yet been migrated.
-- https://wiki.hypr.land/Configuring/

require("design")

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        follow_mouse = 2,
        sensitivity = 0.35,
        scroll_factor = 1.5
    }
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})
