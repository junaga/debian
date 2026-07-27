local feedback = {}
local generations = {}

local function setProperty(window, property, value)
    hl.dispatch(hl.dsp.window.set_prop({
        window = window,
        prop = property,
        value = value
    }))
end

local function set(window, property, value)
    if property == "border_color" then
        setProperty(window, "active_border_color", value)
        setProperty(window, "inactive_border_color", value)
        return
    end

    setProperty(window, property, value)
end

local function restore(window)
    set(window, "opacity", "1")
    set(window, "opacity_override", "0")
    set(window, "border_size", "unset")
    setProperty(window, "active_border_color", "rgba(ffffffff)")
    setProperty(window, "inactive_border_color", "rgba(444444ff)")
    set(window, "rounding", "unset")
    set(window, "rounding_power", "unset")
    set(window, "dim_around", "unset")
end

local function apply(window, properties)
    for property, value in pairs(properties) do
        set(window, property, value)
    end
end

local function animate(frames)
    local window = hl.get_active_window()
    if not window then
        return
    end

    local address = window.address
    local generation = (generations[address] or 0) + 1
    generations[address] = generation
    restore(window)

    for _, frame in ipairs(frames) do
        local function draw()
            if generations[address] ~= generation then
                return
            end

            local target = hl.get_window("address:" .. address)
            if not target then
                generations[address] = nil
                return
            end

            if frame.properties then
                apply(target, frame.properties)
            else
                restore(target)
                generations[address] = nil
            end
        end

        if frame.after == 0 then
            draw()
        else
            hl.timer(draw, { timeout = frame.after, type = "oneshot" })
        end
    end
end

-- Isolate the window for a moment without changing its content or geometry.
function feedback.spotlight()
    animate({
        {
            after = 0,
            properties = {
                border_color = "rgba(e0f2feff) rgba(67e8f9ff) 45deg",
                border_size = "1",
                dim_around = "1",
                rounding = "14"
            }
        },
        {
            after = 80,
            properties = {
                border_color = "rgba(ffffffff) rgba(7dd3fcff) 135deg",
                border_size = "3",
                rounding = "14"
            }
        },
        {
            after = 210,
            properties = {
                border_color = "rgba(a7f3d0ff)",
                border_size = "1"
            }
        },
        { after = 340 }
    })
end

-- Rotate a cool highlight around the exact edge being measured.
function feedback.orbit()
    animate({
        {
            after = 0,
            properties = {
                border_color = "rgba(22d3eeff) rgba(60a5faff) 15deg",
                border_size = "2"
            }
        },
        {
            after = 65,
            properties = {
                border_color = "rgba(60a5faff) rgba(a78bfaff) 105deg",
                border_size = "6"
            }
        },
        {
            after = 145,
            properties = {
                border_color = "rgba(a78bfaff) rgba(2dd4bfff) 195deg",
                border_size = "4"
            }
        },
        {
            after = 230,
            properties = {
                border_color = "rgba(2dd4bfff) rgba(a7f3d0ff) 285deg",
                border_size = "1"
            }
        },
        { after = 350 }
    })
end

-- Press the frame inward, then resolve it into a green confirmation seal.
function feedback.imprint()
    animate({
        {
            after = 0,
            properties = {
                border_color = "rgba(c4b5fdff) rgba(67e8f9ff) 45deg",
                border_size = "9",
                opacity = "0.86 override",
                rounding = "42",
                rounding_power = "1.3"
            }
        },
        {
            after = 75,
            properties = {
                border_color = "rgba(67e8f9ff) rgba(34d399ff) 135deg",
                border_size = "5",
                opacity = "0.98 override",
                rounding = "18",
                rounding_power = "3"
            }
        },
        {
            after = 165,
            properties = {
                border_color = "rgba(34d399ff) rgba(a7f3d0ff) 225deg",
                border_size = "2",
                opacity = "1 override",
                rounding = "10",
                rounding_power = "2"
            }
        },
        { after = 330 }
    })
end

return feedback
